import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nexus_app/core/constants/app_constants.dart';
import 'package:nexus_app/features/auth/domain/entities/user_entity.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_bloc.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_event.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_state.dart';

import '../../mocks/mock_repositories.mocks.dart';

void main() {
  late PersonaNexusBloc bloc;
  late MockPersonaRepository mockPersonaRepo;
  late MockNexusThemeProvider mockThemeProvider;
  late MockNexusHapticChannel mockHapticChannel;

  final mirrorPersona = PersonaEntity.mirror();
  final shadowPersona = PersonaEntity.shadow();
  final primePersona = PersonaEntity.prime();

  setUp(() {
    mockPersonaRepo = MockPersonaRepository();
    mockThemeProvider = MockNexusThemeProvider();
    mockHapticChannel = MockNexusHapticChannel();

    when(mockPersonaRepo.getMirrorPersona()).thenReturn(mirrorPersona);
    when(mockPersonaRepo.getShadowPersona()).thenReturn(shadowPersona);
    when(mockPersonaRepo.getPrimePersona()).thenReturn(primePersona);
    when(mockThemeProvider.triggerFracture()).thenReturn(null);
    when(mockThemeProvider.activateArena()).thenReturn(null);
    when(mockThemeProvider.resetToMirror()).thenReturn(null);
    when(mockHapticChannel.triggerFractureHaptic()).thenAnswer((_) async {});
    when(mockHapticChannel.triggerArenaHaptic()).thenAnswer((_) async {});

    bloc = PersonaNexusBloc(
      personaRepository: mockPersonaRepo,
      themeProvider: mockThemeProvider,
      hapticChannel: mockHapticChannel,
    );
  });

  tearDown(() => bloc.close());

  group('PersonaNexusBloc', () {
    test('initial state is PersonaNexusInitial', () {
      expect(bloc.state, const PersonaNexusInitial());
    });

    blocTest<PersonaNexusBloc, PersonaNexusState>(
      'emits [PersonaNexusLoading, MirrorActive] on PersonaInitialized',
      build: () => bloc,
      act: (b) => b.add(const PersonaInitialized(userId: 'test-user-1')),
      expect: () => [
        const PersonaNexusLoading(),
        isA<MirrorActive>()
            .having((s) => s.persona.type, 'persona.type', PersonaType.mirror)
            .having((s) => s.interactionCount, 'interactionCount', 0)
            .having(
              (s) => s.currentQuestion,
              'currentQuestion',
              isNotEmpty,
            ),
      ],
      verify: (_) {
        verify(mockPersonaRepo.getMirrorPersona()).called(1);
      },
    );

    blocTest<PersonaNexusBloc, PersonaNexusState>(
      'InteractionRecorded increments interactionCount',
      build: () => bloc,
      seed: () => MirrorActive(
        user: _testUser(),
        persona: mirrorPersona,
        currentQuestion: 'Who are you?',
        interactionCount: 10,
      ),
      act: (b) => b.add(
        const InteractionRecorded(
          userInput: 'test input',
          aiResponse: 'test response',
        ),
      ),
      expect: () => [
        isA<MirrorActive>()
            .having((s) => s.interactionCount, 'interactionCount', 11),
      ],
    );

    blocTest<PersonaNexusBloc, PersonaNexusState>(
      'auto-fracture at ${AppConstants.fractureThreshold} interactions',
      build: () => bloc,
      seed: () => MirrorActive(
        user: _testUser(),
        persona: mirrorPersona,
        currentQuestion: 'Who are you?',
        interactionCount: AppConstants.fractureThreshold - 1,
      ),
      act: (b) => b.add(
        const InteractionRecorded(
          userInput: 'final push',
          aiResponse: 'the mirror cracks',
        ),
      ),
      expect: () => [
        isA<FractureTriggered>()
            .having(
              (s) => s.shadowPersona.type,
              'shadowPersona.type',
              PersonaType.shadow,
            )
            .having(
              (s) => s.primePersona.type,
              'primePersona.type',
              PersonaType.prime,
            ),
      ],
      verify: (_) {
        verify(mockHapticChannel.triggerFractureHaptic()).called(1);
        verify(mockThemeProvider.triggerFracture()).called(1);
      },
    );

    blocTest<PersonaNexusBloc, PersonaNexusState>(
      'ShadowPersonaChosen transitions from FractureTriggered → ShadowNexusActive',
      build: () => bloc,
      seed: () => FractureTriggered(
        user: _testUser(),
        shadowPersona: shadowPersona,
        primePersona: primePersona,
      ),
      act: (b) => b.add(const ShadowPersonaChosen()),
      expect: () => [
        isA<ShadowNexusActive>().having(
          (s) => s.persona.type,
          'persona.type',
          PersonaType.shadow,
        ),
      ],
    );

    blocTest<PersonaNexusBloc, PersonaNexusState>(
      'PrimePersonaChosen transitions from FractureTriggered → PrimeNexusActive',
      build: () => bloc,
      seed: () => FractureTriggered(
        user: _testUser(),
        shadowPersona: shadowPersona,
        primePersona: primePersona,
      ),
      act: (b) => b.add(const PrimePersonaChosen()),
      expect: () => [
        isA<PrimeNexusActive>().having(
          (s) => s.persona.type,
          'persona.type',
          PersonaType.prime,
        ),
      ],
    );

    blocTest<PersonaNexusBloc, PersonaNexusState>(
      'ArenaSessionStarted emits ArenaSessionActive with scenario',
      build: () {
        when(mockPersonaRepo.getUnlockedPersona(any)).thenReturn(null);
        return bloc;
      },
      seed: () => ShadowNexusActive(
        user: _testUser(),
        persona: shadowPersona,
      ),
      act: (b) => b.add(
        ArenaSessionStarted(
          scenario: ArenaScenario.builtIn.first,
          personaId: 'shadow',
        ),
      ),
      expect: () => [
        isA<ArenaSessionActive>()
            .having(
              (s) => s.scenario.id,
              'scenario.id',
              ArenaScenario.builtIn.first.id,
            )
            .having((s) => s.tensionLevel, 'tensionLevel', 0),
      ],
      verify: (_) {
        verify(mockThemeProvider.activateArena()).called(1);
      },
    );

    blocTest<PersonaNexusBloc, PersonaNexusState>(
      'PersonaReset returns to MirrorActive with reset message',
      build: () => bloc,
      seed: () => ShadowNexusActive(
        user: _testUser(),
        persona: shadowPersona,
      ),
      act: (b) => b.add(const PersonaReset()),
      expect: () => [
        isA<MirrorActive>()
            .having((s) => s.persona.type, 'persona.type', PersonaType.mirror)
            .having(
              (s) => s.currentQuestion,
              'currentQuestion',
              contains('returned to the beginning'),
            ),
      ],
      verify: (_) {
        verify(mockThemeProvider.resetToMirror()).called(1);
      },
    );

    blocTest<PersonaNexusBloc, PersonaNexusState>(
      'WeaknessAnalysisRequested emits WeaknessAnalysisReady',
      build: () => bloc,
      seed: () => ArenaSessionActive(
        user: _testUser(),
        persona: shadowPersona,
        scenario: ArenaScenario.builtIn.first,
        tensionLevel: 50,
      ),
      act: (b) => b.add(const WeaknessAnalysisRequested()),
      expect: () => [
        isA<WeaknessAnalysisReady>().having(
          (s) => s.weaknesses,
          'weaknesses',
          isNotEmpty,
        ),
      ],
    );
  });
}

UserEntity _testUser() => UserEntity(
      id: 'test-user-1',
      email: 'test@nexus.app',
      displayName: 'Seeker',
      interactionCount: 0,
      unlockedPersonaIds: const [],
      hasArenaAccess: false,
      hasLegacyAccess: false,
      createdAt: DateTime(2026),
    );
