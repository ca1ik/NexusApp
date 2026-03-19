import 'package:dartz/dartz.dart';
import 'package:nexus_app/core/errors/failures.dart';
import 'package:nexus_app/features/conversation/domain/entities/message_entity.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';

abstract interface class ConversationRepository {
  /// Sends a message to the LLM using the given [persona] and
  /// RAG context retrieved from the Vector DB for [userId].
  Future<Either<LlmFailure, MessageEntity>> sendMessage({
    required String userId,
    required String content,
    required PersonaEntity persona,
    required List<MessageEntity> history,
  });

  /// Loads the top-K contextual memories for the given [userId].
  Future<Either<VectorDbFailure, String>> loadRagContext({
    required String userId,
    required String queryText,
  });

  /// Stores an interaction (input + response) in the Vector DB
  /// for future RAG retrieval.
  Future<Either<VectorDbFailure, void>> storeInteraction({
    required String userId,
    required String userInput,
    required String aiResponse,
  });
}
