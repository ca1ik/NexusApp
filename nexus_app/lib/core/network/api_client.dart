import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:nexus_app/core/constants/app_constants.dart';
import 'package:nexus_app/core/errors/exceptions.dart';
import 'package:nexus_app/core/network/network_interceptors.dart';

// ── Value objects ─────────────────────────────────────────────────────────────

/// A single example for few-shot prompting.
class FewShotExample {
  const FewShotExample({
    required this.userInput,
    required this.assistantResponse,
  });

  final String userInput;
  final String assistantResponse;
}

/// Parsed LLM completion result.
class LlmResponse {
  const LlmResponse({required this.content, required this.usage});

  final String content;
  final Map<String, dynamic> usage;
}

/// A single Pinecone similarity-search match.
class VectorMatch {
  const VectorMatch({
    required this.id,
    required this.score,
    required this.metadata,
  });

  final String id;
  final double score;
  final Map<String, dynamic> metadata;
}

// ── Client ────────────────────────────────────────────────────────────────────

/// Central HTTP client that handles all LLM (OpenAI) and
/// Vector DB (Pinecone) communication with automatic retry logic.
class NexusApiClient {
  NexusApiClient({Logger? logger}) : _log = logger ?? Logger() {
    _llmDio = _buildDio(
      baseUrl: AppConstants.openAiBaseUrl,
      apiKey: AppConstants.openAiApiKey,
    );
    _embeddingDio = _buildDio(
      baseUrl: AppConstants.openAiBaseUrl,
      apiKey: AppConstants.openAiApiKey,
    );
    _vectorDio = _buildDio(
      baseUrl: AppConstants.pineconeBaseUrl,
      apiKey: AppConstants.pineconeApiKey,
    );
  }

  final Logger _log;
  late final Dio _llmDio;
  late final Dio _embeddingDio;
  late final Dio _vectorDio;

  Dio _buildDio({required String baseUrl, required String apiKey}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.llmTimeout,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );
    dio.interceptors.addAll([
      NexusLogInterceptor(_log),
      NexusRetryInterceptor(),
    ]);
    return dio;
  }

  // ── LLM ────────────────────────────────────────────────────────────────────

  /// Sends a chat-completion request with:
  ///   • system prompt that encodes the active persona
  ///   • few-shot examples to steer the persona's style
  ///   • RAG context retrieved from the Vector DB
  ///   • full conversation history
  Future<LlmResponse> chatCompletion({
    required String systemPrompt,
    required List<FewShotExample> fewShotExamples,
    required List<Map<String, String>> conversationHistory,
    String? ragContext,
  }) async {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': _buildSystemPrompt(systemPrompt, ragContext),
      },
      ..._buildFewShotMessages(fewShotExamples),
      ...conversationHistory,
    ];

    try {
      final response = await _llmDio.post<Map<String, dynamic>>(
        '/chat/completions',
        data: jsonEncode({
          'model': AppConstants.llmModel,
          'messages': messages,
          'temperature': 0.85,
          'max_tokens': 600,
          'presence_penalty': 0.6,
          'frequency_penalty': 0.3,
        }),
      );
      final data = response.data!;
      final choices = data['choices'] as List<dynamic>? ?? const [];
      if (choices.isEmpty) {
        throw const LlmException(message: 'LLM returned no choices');
      }
      final firstChoice = Map<String, dynamic>.from(choices.first as Map);
      final message = Map<String, dynamic>.from(firstChoice['message'] as Map);
      final content = message['content'] as String? ?? '';
      return LlmResponse(
        content: content.trim(),
        usage: (data['usage'] as Map<String, dynamic>?) ?? const {},
      );
    } on DioException catch (e) {
      _log.e('LLM request failed', error: e);
      throw LlmException(
        message: e.response?.data?.toString() ?? e.message ?? 'LLM failed',
      );
    }
  }

  // ── Embeddings ──────────────────────────────────────────────────────────────

  /// Generates a 1536-dim embedding for [text] using text-embedding-3-small.
  Future<List<double>> generateEmbedding(String text) async {
    try {
      final response = await _embeddingDio.post<Map<String, dynamic>>(
        '/embeddings',
        data: jsonEncode({'model': AppConstants.embeddingModel, 'input': text}),
      );
      final items = response.data!['data'] as List<dynamic>? ?? const [];
      if (items.isEmpty) {
        throw const VectorDbException(message: 'Embedding response was empty');
      }
      final firstItem = Map<String, dynamic>.from(items.first as Map);
      final raw = firstItem['embedding'] as List<dynamic>? ?? const [];
      return raw.map((v) => (v as num).toDouble()).toList();
    } on DioException catch (e) {
      _log.e('Embedding generation failed', error: e);
      throw VectorDbException(message: e.message ?? 'Embedding failed');
    }
  }

  // ── Pinecone ────────────────────────────────────────────────────────────────

  /// Upserts a vector record into the Pinecone index.
  Future<void> upsertVector({
    required String id,
    required List<double> embedding,
    required Map<String, String> metadata,
  }) async {
    try {
      await _vectorDio.post<void>(
        '/vectors/upsert',
        data: jsonEncode({
          'vectors': [
            {'id': id, 'values': embedding, 'metadata': metadata},
          ],
        }),
      );
    } on DioException catch (e) {
      _log.e('Vector upsert failed', error: e);
      throw VectorDbException(message: e.message ?? 'Upsert failed');
    }
  }

  /// Queries Pinecone for the [topK] most semantically similar vectors.
  Future<List<VectorMatch>> querySimilar({
    required List<double> embedding,
    int topK = AppConstants.ragTopK,
    Map<String, dynamic>? filter,
  }) async {
    try {
      final response = await _vectorDio.post<Map<String, dynamic>>(
        '/query',
        data: jsonEncode({
          'vector': embedding,
          'topK': topK,
          'includeMetadata': true,
          if (filter != null) 'filter': filter,
        }),
      );
      final matches =
          (response.data!['matches'] as List<dynamic>? ?? <dynamic>[]).map((m) {
        final map = m as Map<String, dynamic>;
        return VectorMatch(
          id: map['id'] as String,
          score: (map['score'] as num).toDouble(),
          metadata: (map['metadata'] as Map<String, dynamic>?) ?? const {},
        );
      }).toList();
      return matches;
    } on DioException catch (e) {
      _log.e('Vector query failed', error: e);
      throw VectorDbException(message: e.message ?? 'Query failed');
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _buildSystemPrompt(String base, String? ragContext) {
    if (ragContext == null || ragContext.isEmpty) return base;
    return '$base\n\n--- RECALLED MEMORY ---\n$ragContext\n--- END MEMORY ---';
  }

  List<Map<String, String>> _buildFewShotMessages(
    List<FewShotExample> examples,
  ) =>
      examples
          .expand(
            (e) => [
              {'role': 'user', 'content': e.userInput},
              {'role': 'assistant', 'content': e.assistantResponse},
            ],
          )
          .toList();
}
