import 'package:dartz/dartz.dart';
import 'package:nexus_app/core/errors/exceptions.dart';
import 'package:nexus_app/core/errors/failures.dart';
import 'package:nexus_app/features/conversation/data/datasources/llm_datasource.dart';
import 'package:nexus_app/features/conversation/data/datasources/vector_db_datasource.dart';
import 'package:nexus_app/features/conversation/domain/entities/message_entity.dart';
import 'package:nexus_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';
import 'package:uuid/uuid.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  ConversationRepositoryImpl({
    required LlmDataSource llmDataSource,
    required VectorDbDataSource vectorDbDataSource,
  }) : _llm = llmDataSource,
       _vectorDb = vectorDbDataSource;

  final LlmDataSource _llm;
  final VectorDbDataSource _vectorDb;
  final Uuid _uuid = const Uuid();

  @override
  Future<Either<LlmFailure, MessageEntity>> sendMessage({
    required String userId,
    required String content,
    required PersonaEntity persona,
    required List<MessageEntity> history,
  }) async {
    try {
      // 1. Retrieve RAG context from Vector DB
      String ragContext = '';
      try {
        ragContext = await _vectorDb.retrieveContext(
          userId: userId,
          queryText: content,
        );
      } catch (_) {
        // RAG is best-effort; LLM can still respond without it
      }

      // 2. Build conversation history for LLM
      final historyMaps = history
          .map((m) => m.toConversationMessage())
          .toList();

      // 3. Add the new user message
      historyMaps.add({'role': 'user', 'content': content});

      // 4. Call LLM
      final responseText = await _llm.generateResponse(
        persona: persona,
        conversationHistory: historyMaps,
        ragContext: ragContext.isNotEmpty ? ragContext : null,
      );

      final message = MessageEntity(
        id: _uuid.v4(),
        content: responseText,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        personaType: persona.type,
      );

      // 5. Fire-and-forget: store the exchange for future RAG
      unawaited(
        _vectorDb.storeInteraction(
          userId: userId,
          userInput: content,
          aiResponse: responseText,
        ),
      );

      return Right(message);
    } on LlmException catch (e) {
      return Left(LlmFailure(message: e.message));
    } catch (e) {
      return Left(LlmFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<VectorDbFailure, String>> loadRagContext({
    required String userId,
    required String queryText,
  }) async {
    try {
      final context = await _vectorDb.retrieveContext(
        userId: userId,
        queryText: queryText,
      );
      return Right(context);
    } on VectorDbException catch (e) {
      return Left(VectorDbFailure(message: e.message));
    }
  }

  @override
  Future<Either<VectorDbFailure, void>> storeInteraction({
    required String userId,
    required String userInput,
    required String aiResponse,
  }) async {
    try {
      await _vectorDb.storeInteraction(
        userId: userId,
        userInput: userInput,
        aiResponse: aiResponse,
      );
      return const Right(null);
    } on VectorDbException catch (e) {
      return Left(VectorDbFailure(message: e.message));
    }
  }
}

// Suppresses unawaited-futures lint for fire-and-forget operations.
void unawaited(Future<void> future) {}
