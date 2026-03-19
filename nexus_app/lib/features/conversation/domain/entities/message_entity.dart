import 'package:equatable/equatable.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';

enum MessageRole { user, assistant, system }

class MessageEntity extends Equatable {
  const MessageEntity({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    required this.personaType,
    this.embedding,
  });

  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final PersonaType personaType;

  /// 1536-dim vector embedding — null until stored in Vector DB.
  final List<double>? embedding;

  Map<String, String> toConversationMessage() => {
    'role': role.name,
    'content': content,
  };

  @override
  List<Object?> get props => [id, content, role, timestamp, personaType];
}
