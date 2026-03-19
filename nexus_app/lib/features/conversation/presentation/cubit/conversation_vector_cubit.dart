import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexus_app/features/conversation/domain/entities/message_entity.dart';
import 'package:nexus_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:nexus_app/features/conversation/presentation/cubit/conversation_vector_state.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';

/// Manages the active conversation thread and its Vector DB memory.
///
/// State flow:
///   ConversationInitial → ConversationLoading → ConversationLoaded
///                                            ↘ ConversationError
class ConversationVectorCubit extends Cubit<ConversationVectorState> {
  ConversationVectorCubit({required ConversationRepository repository})
    : _repo = repository,
      super(const ConversationInitial());

  final ConversationRepository _repo;

  // ── Actions ─────────────────────────────────────────────────────────────────

  /// Initialises an empty conversation for [userId].
  void startConversation() =>
      emit(const ConversationLoaded(messages: [], ragContext: ''));

  /// Sends [content] to the LLM via the given [persona] and
  /// appends both the user message and the AI response to state.
  Future<void> sendMessage({
    required String userId,
    required String content,
    required PersonaEntity persona,
  }) async {
    final current = _currentLoaded;
    if (current == null) return;

    // Append the user's message immediately
    final userMessage = MessageEntity(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      personaType: persona.type,
    );
    emit(
      current.copyWith(
        messages: [...current.messages, userMessage],
        isStreaming: true,
      ),
    );

    // Call repository (LLM + RAG)
    final result = await _repo.sendMessage(
      userId: userId,
      content: content,
      persona: persona,
      history: current.messages,
    );

    result.fold((failure) => emit(ConversationError(failure.message)), (
      aiMessage,
    ) {
      final loaded = state as ConversationLoaded;
      emit(
        loaded.copyWith(
          messages: [...loaded.messages, aiMessage],
          isStreaming: false,
        ),
      );
    });
  }

  /// Pre-loads the RAG context for the next user message.
  Future<void> preloadContext({
    required String userId,
    required String queryHint,
  }) async {
    final current = _currentLoaded;
    if (current == null) return;

    final result = await _repo.loadRagContext(
      userId: userId,
      queryText: queryHint,
    );

    result.fold(
      (_) {}, // silently ignore; RAG is best-effort
      (context) => emit(current.copyWith(ragContext: context)),
    );
  }

  /// Clears all messages and returns to initial state.
  void clearConversation() => emit(const ConversationInitial());

  // ── Helpers ─────────────────────────────────────────────────────────────────

  ConversationLoaded? get _currentLoaded {
    final s = state;
    if (s is ConversationLoaded) return s;
    startConversation();
    return state is ConversationLoaded ? state as ConversationLoaded : null;
  }
}
