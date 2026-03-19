import 'package:equatable/equatable.dart';
import 'package:nexus_app/features/conversation/domain/entities/message_entity.dart';

sealed class ConversationVectorState extends Equatable {
  const ConversationVectorState();

  @override
  List<Object?> get props => const [];
}

final class ConversationInitial extends ConversationVectorState {
  const ConversationInitial();
}

final class ConversationLoading extends ConversationVectorState {
  const ConversationLoading();
}

final class ConversationLoaded extends ConversationVectorState {
  const ConversationLoaded({
    required this.messages,
    this.ragContext = '',
    this.isStreaming = false,
  });

  /// Full conversation history (oldest → newest).
  final List<MessageEntity> messages;

  /// The retrieved RAG context shown as a subtle indicator.
  final String ragContext;

  /// True while the LLM response is being streamed.
  final bool isStreaming;

  ConversationLoaded copyWith({
    List<MessageEntity>? messages,
    String? ragContext,
    bool? isStreaming,
  }) => ConversationLoaded(
    messages: messages ?? this.messages,
    ragContext: ragContext ?? this.ragContext,
    isStreaming: isStreaming ?? this.isStreaming,
  );

  @override
  List<Object?> get props => [messages, ragContext, isStreaming];
}

final class ConversationError extends ConversationVectorState {
  const ConversationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
