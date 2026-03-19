import 'package:nexus_app/core/errors/exceptions.dart';
import 'package:nexus_app/core/network/api_client.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';

abstract interface class LlmDataSource {
  Future<String> generateResponse({
    required PersonaEntity persona,
    required List<Map<String, String>> conversationHistory,
    String? ragContext,
  });
}

class LlmDataSourceImpl implements LlmDataSource {
  const LlmDataSourceImpl({required NexusApiClient apiClient})
    : _client = apiClient;

  final NexusApiClient _client;

  @override
  Future<String> generateResponse({
    required PersonaEntity persona,
    required List<Map<String, String>> conversationHistory,
    String? ragContext,
  }) async {
    try {
      final result = await _client.chatCompletion(
        systemPrompt: persona.systemPrompt,
        fewShotExamples: persona.fewShotExamples,
        conversationHistory: conversationHistory,
        ragContext: ragContext,
      );
      return result.content;
    } on LlmException {
      rethrow;
    } catch (e) {
      throw LlmException(message: e.toString());
    }
  }
}
