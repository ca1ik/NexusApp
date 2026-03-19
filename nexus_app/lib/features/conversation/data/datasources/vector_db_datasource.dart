import 'package:nexus_app/core/errors/exceptions.dart';
import 'package:nexus_app/core/network/api_client.dart';

abstract interface class VectorDbDataSource {
  /// Generates an embedding for [text] and queries Pinecone for
  /// the [topK] most contextually similar past interactions.
  /// Returns a formatted string of recalled memories.
  Future<String> retrieveContext({
    required String userId,
    required String queryText,
    int topK = 5,
  });

  /// Embeds and stores [userInput]+[aiResponse] as a linked pair.
  Future<void> storeInteraction({
    required String userId,
    required String userInput,
    required String aiResponse,
  });
}

class VectorDbDataSourceImpl implements VectorDbDataSource {
  const VectorDbDataSourceImpl({required NexusApiClient apiClient})
    : _client = apiClient;

  final NexusApiClient _client;

  @override
  Future<String> retrieveContext({
    required String userId,
    required String queryText,
    int topK = 5,
  }) async {
    try {
      final embedding = await _client.generateEmbedding(queryText);
      final matches = await _client.querySimilar(
        embedding: embedding,
        topK: topK,
        filter: {'userId': userId},
      );

      if (matches.isEmpty) return '';

      final buffer = StringBuffer();
      for (final m in matches) {
        final userMsg = m.metadata['userInput'] as String? ?? '';
        final aiMsg = m.metadata['aiResponse'] as String? ?? '';
        if (userMsg.isNotEmpty) {
          buffer
            ..writeln('User: $userMsg')
            ..writeln('Nexus: $aiMsg')
            ..writeln();
        }
      }
      return buffer.toString().trim();
    } on VectorDbException {
      rethrow;
    } catch (e) {
      throw VectorDbException(message: 'Context retrieval failed: $e');
    }
  }

  @override
  Future<void> storeInteraction({
    required String userId,
    required String userInput,
    required String aiResponse,
  }) async {
    try {
      final combinedText = '$userInput\n$aiResponse';
      final embedding = await _client.generateEmbedding(combinedText);
      final id = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
      await _client.upsertVector(
        id: id,
        embedding: embedding,
        metadata: {
          'userId': userId,
          'userInput': userInput,
          'aiResponse': aiResponse,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } on VectorDbException {
      rethrow;
    } catch (e) {
      throw VectorDbException(message: 'Store interaction failed: $e');
    }
  }
}
