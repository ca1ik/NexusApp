import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nexus_app/core/errors/failures.dart';
import 'package:nexus_app/features/conversation/domain/entities/message_entity.dart';
import 'package:nexus_app/features/conversation/presentation/cubit/conversation_vector_cubit.dart';
import 'package:nexus_app/features/conversation/presentation/cubit/conversation_vector_state.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';

import '../../mocks/mock_repositories.mocks.dart';

void main() {
  late ConversationVectorCubit cubit;
  late MockConversationRepository mockRepo;

  final testPersona = PersonaEntity.mirror();

  final testResponse = MessageEntity(
    id: 'resp-1',
    content: 'The mirror reflects what you allow it to see.',
    role: MessageRole.assistant,
    timestamp: DateTime(2026, 3, 17),
    personaType: PersonaType.mirror,
  );

  setUp(() {
    mockRepo = MockConversationRepository();
    cubit = ConversationVectorCubit(repository: mockRepo);
  });

  tearDown(() => cubit.close());

  group('ConversationVectorCubit', () {
    test('initial state is ConversationInitial', () {
      expect(cubit.state, const ConversationInitial());
    });

    test('startConversation emits ConversationLoaded with empty messages', () {
      cubit.startConversation();
      expect(
        cubit.state,
        isA<ConversationLoaded>()
            .having((s) => s.messages, 'messages', isEmpty)
            .having((s) => s.ragContext, 'ragContext', ''),
      );
    });

    blocTest<ConversationVectorCubit, ConversationVectorState>(
      'sendMessage success: shows streaming → appends user msg → appends AI msg',
      setUp: () {
        when(
          mockRepo.loadRagContext(
            userId: anyNamed('userId'),
            queryText: anyNamed('queryText'),
          ),
        ).thenAnswer((_) async => const Right('some context from vector db'));

        when(
          mockRepo.sendMessage(
            userId: anyNamed('userId'),
            content: anyNamed('content'),
            persona: anyNamed('persona'),
            history: anyNamed('history'),
          ),
        ).thenAnswer((_) async => Right(testResponse));

        when(
          mockRepo.storeInteraction(
            userId: anyNamed('userId'),
            userInput: anyNamed('userInput'),
            aiResponse: anyNamed('aiResponse'),
          ),
        ).thenAnswer((_) async => const Right(null));
      },
      build: () => cubit,
      seed: () => const ConversationLoaded(messages: [], ragContext: ''),
      act: (c) => c.sendMessage(
        userId: 'test-user',
        content: 'Tell me who I am',
        persona: testPersona,
      ),
      expect: () => [
        // 1) streaming starts — user msg appended
        isA<ConversationLoaded>()
            .having((s) => s.isStreaming, 'isStreaming', true)
            .having((s) => s.messages.length, 'messages.length', 1)
            .having(
              (s) => s.messages.first.role,
              'first message role',
              MessageRole.user,
            ),
        // 2) AI response appended, streaming done
        isA<ConversationLoaded>()
            .having((s) => s.isStreaming, 'isStreaming', false)
            .having((s) => s.messages.length, 'messages.length', 2)
            .having(
              (s) => s.messages.last.content,
              'last message content',
              testResponse.content,
            ),
      ],
      verify: (_) {
        verify(
          mockRepo.sendMessage(
            userId: 'test-user',
            content: 'Tell me who I am',
            persona: testPersona,
            history: anyNamed('history'),
          ),
        ).called(1);
      },
    );

    blocTest<ConversationVectorCubit, ConversationVectorState>(
      'sendMessage failure: emits ConversationError on LLM failure',
      setUp: () {
        when(
          mockRepo.loadRagContext(
            userId: anyNamed('userId'),
            queryText: anyNamed('queryText'),
          ),
        ).thenAnswer((_) async => const Right(''));

        when(
          mockRepo.sendMessage(
            userId: anyNamed('userId'),
            content: anyNamed('content'),
            persona: anyNamed('persona'),
            history: anyNamed('history'),
          ),
        ).thenAnswer(
          (_) async => const Left(LlmFailure(message: 'LLM timeout')),
        );
      },
      build: () => cubit,
      seed: () => const ConversationLoaded(messages: [], ragContext: ''),
      act: (c) => c.sendMessage(
        userId: 'test-user',
        content: 'Something that fails',
        persona: testPersona,
      ),
      expect: () => [
        isA<ConversationLoaded>().having(
          (s) => s.isStreaming,
          'isStreaming',
          true,
        ),
        isA<ConversationError>().having(
          (s) => s.message,
          'error message',
          contains('LLM timeout'),
        ),
      ],
    );

    blocTest<ConversationVectorCubit, ConversationVectorState>(
      'preloadContext loads RAG context into state',
      setUp: () {
        when(
          mockRepo.loadRagContext(
            userId: anyNamed('userId'),
            queryText: anyNamed('queryText'),
          ),
        ).thenAnswer(
          (_) async => const Right('preloaded vector context'),
        );
      },
      build: () => cubit,
      seed: () => const ConversationLoaded(messages: [], ragContext: ''),
      act: (c) => c.preloadContext(
        userId: 'test-user',
        queryHint: 'salary negotiation',
      ),
      expect: () => [
        isA<ConversationLoaded>().having(
          (s) => s.ragContext,
          'ragContext',
          'preloaded vector context',
        ),
      ],
    );

    test('clearConversation resets to ConversationInitial', () {
      cubit.startConversation();
      expect(cubit.state, isA<ConversationLoaded>());
      cubit.clearConversation();
      expect(cubit.state, const ConversationInitial());
    });
  });
}
