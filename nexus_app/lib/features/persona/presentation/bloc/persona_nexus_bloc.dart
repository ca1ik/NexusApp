import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexus_app/core/constants/app_constants.dart';
import 'package:nexus_app/core/platform/haptic_channel.dart';
import 'package:nexus_app/core/theme/theme_provider.dart';
import 'package:nexus_app/features/auth/domain/entities/user_entity.dart';
import 'package:nexus_app/features/persona/domain/repositories/persona_repository.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_event.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_state.dart';

/// The psychological engine of The Nexus of Power.
///
/// Manages persona phase transitions:
///   Mirror → [500 interactions] → Fracture → Shadow or Prime → Arena
class PersonaNexusBloc extends Bloc<PersonaNexusEvent, PersonaNexusState> {
  PersonaNexusBloc({
    required PersonaRepository personaRepository,
    required NexusThemeProvider themeProvider,
    required NexusHapticChannel hapticChannel,
  })  : _repo = personaRepository,
        _theme = themeProvider,
        _haptic = hapticChannel,
        super(const PersonaNexusInitial()) {
    on<PersonaInitialized>(_onInitialized);
    on<InteractionRecorded>(_onInteractionRecorded);
    on<FractureInitiated>(_onFractureInitiated);
    on<ShadowPersonaChosen>(_onShadowChosen);
    on<PrimePersonaChosen>(_onPrimeChosen);
    on<ArenaSessionStarted>(_onArenaStarted);
    on<WeaknessAnalysisRequested>(_onWeaknessAnalysis);
    on<PersonaUnlocked>(_onPersonaUnlocked);
    on<PersonaReset>(_onReset);
  }

  final PersonaRepository _repo;
  final NexusThemeProvider _theme;
  final NexusHapticChannel _haptic;

  // Tracks unlocked add-on persona IDs per session
  final List<String> _unlockedPersonaIds = [];

  // ── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _onInitialized(
    PersonaInitialized event,
    Emitter<PersonaNexusState> emit,
  ) async {
    emit(const PersonaNexusLoading());
    _theme.resetToMirror();
    // Placeholder user until AuthBloc syncs the real entity
    final placeholder = _buildPlaceholder(event.userId);
    emit(
      MirrorActive(
        user: placeholder,
        persona: _repo.getMirrorPersona(),
        currentQuestion:
            'Before anything else — who do you think you are, right now?',
        interactionCount: 0,
      ),
    );
  }

  Future<void> _onInteractionRecorded(
    InteractionRecorded event,
    Emitter<PersonaNexusState> emit,
  ) async {
    final s = state;
    if (s is MirrorActive) {
      final newCount = s.interactionCount + 1;
      final updatedUser = s.user.copyWith(interactionCount: newCount);

      // Auto-fracture after threshold
      if (newCount >= AppConstants.fractureThreshold) {
        await _triggerFracture(updatedUser, emit);
        return;
      }

      emit(
        MirrorActive(
          user: updatedUser,
          persona: s.persona,
          currentQuestion: event.aiResponse,
          interactionCount: newCount,
        ),
      );
    } else if (s is ShadowNexusActive) {
      emit(
        ShadowNexusActive(
          user: s.user,
          persona: s.persona,
          latestInsight: event.aiResponse,
        ),
      );
    } else if (s is PrimeNexusActive) {
      emit(
        PrimeNexusActive(
          user: s.user,
          persona: s.persona,
          latestInsight: event.aiResponse,
        ),
      );
    } else if (s is ArenaSessionActive) {
      // Increase tension on each exchange (caps at 100)
      final newTension = (s.tensionLevel + 8).clamp(0, 100);
      if (newTension >= 60) {
        await _haptic.triggerArenaHaptic();
      }
      emit(
        ArenaSessionActive(
          user: s.user,
          persona: s.persona,
          scenario: s.scenario,
          tensionLevel: newTension,
        ),
      );
    }
  }

  Future<void> _onFractureInitiated(
    FractureInitiated event,
    Emitter<PersonaNexusState> emit,
  ) async {
    final user = _extractUser();
    if (user == null) return;
    await _triggerFracture(user, emit);
  }

  Future<void> _onShadowChosen(
    ShadowPersonaChosen event,
    Emitter<PersonaNexusState> emit,
  ) async {
    final user = _extractUser();
    if (user == null) return;
    _theme.triggerFracture();
    emit(ShadowNexusActive(user: user, persona: _repo.getShadowPersona()));
  }

  Future<void> _onPrimeChosen(
    PrimePersonaChosen event,
    Emitter<PersonaNexusState> emit,
  ) async {
    final user = _extractUser();
    if (user == null) return;
    _theme.activateArena();
    emit(PrimeNexusActive(user: user, persona: _repo.getPrimePersona()));
  }

  Future<void> _onArenaStarted(
    ArenaSessionStarted event,
    Emitter<PersonaNexusState> emit,
  ) async {
    final user = _extractUser();
    if (user == null) return;
    _theme.activateArena();
    await _haptic.triggerArenaHaptic();

    final persona =
        _repo.getUnlockedPersona(event.personaId) ?? _repo.getShadowPersona();

    emit(
      ArenaSessionActive(
        user: user,
        persona: persona,
        scenario: event.scenario,
      ),
    );
  }

  Future<void> _onWeaknessAnalysis(
    WeaknessAnalysisRequested event,
    Emitter<PersonaNexusState> emit,
  ) async {
    // Placeholder: real implementation would call LLM with stored Vector context
    emit(
      WeaknessAnalysisReady(
        weaknesses: const [
          'Avoidance under social pressure',
          'Need for external validation before action',
          'Over-preparation as a procrastination mechanism',
        ],
        previousState: state,
      ),
    );
  }

  Future<void> _onPersonaUnlocked(
    PersonaUnlocked event,
    Emitter<PersonaNexusState> emit,
  ) async {
    _unlockedPersonaIds.add(event.personaId);
    // Re-emit current state to refresh the UI persona list
    emit(state);
  }

  Future<void> _onReset(
    PersonaReset event,
    Emitter<PersonaNexusState> emit,
  ) async {
    _theme.resetToMirror();
    final user = _extractUser();
    emit(
      MirrorActive(
        user: user ?? _buildPlaceholder('unknown'),
        persona: _repo.getMirrorPersona(),
        currentQuestion:
            'You have returned to the beginning. What did the experience teach you?',
        interactionCount: user?.interactionCount ?? 0,
      ),
    );
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<void> _triggerFracture(
    UserEntity user,
    Emitter<PersonaNexusState> emit,
  ) async {
    await _haptic.triggerFractureHaptic();
    _theme.triggerFracture();
    emit(
      FractureTriggered(
        user: user,
        shadowPersona: _repo.getShadowPersona(),
        primePersona: _repo.getPrimePersona(),
      ),
    );
  }

  UserEntity? _extractUser() {
    final s = state;
    return switch (s) {
      MirrorActive() => s.user,
      ShadowNexusActive() => s.user,
      PrimeNexusActive() => s.user,
      ArenaSessionActive() => s.user,
      FractureTriggered() => s.user,
      _ => null,
    };
  }

  UserEntity _buildPlaceholder(String userId) => UserEntity(
        id: userId,
        email: '',
        displayName: 'Seeker',
        interactionCount: 0,
        unlockedPersonaIds: const [],
        hasArenaAccess: false,
        hasLegacyAccess: false,
        createdAt: DateTime.now(),
      );
}
