// ================================================================
// App-wide constants — use dart-define for production secrets:
//   flutter build apk --dart-define=OPENAI_API_KEY=sk-...
// ================================================================
abstract final class AppConstants {
  // ── LLM ──────────────────────────────────────────────────────────────────────
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String openAiApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: 'REPLACE_ME',
  );
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'REPLACE_ME',
  );
  static const String llmModel = 'gpt-4o';
  static const String embeddingModel = 'text-embedding-3-small';

  // ── Vector DB (Pinecone) ──────────────────────────────────────────────────────
  static const String pineconeApiKey = String.fromEnvironment(
    'PINECONE_API_KEY',
    defaultValue: 'REPLACE_ME',
  );
  // Replace with your actual Pinecone host after creating an index:
  static const String pineconeBaseUrl =
      'https://nexus-vectors-YOUR_ENV.svc.pinecone.io';
  static const String pineconeIndexName = 'nexus-vectors';
  static const int vectorDimension = 1536;
  static const int ragTopK = 5;

  // ── RevenueCat ────────────────────────────────────────────────────────────────
  static const String revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'REPLACE_ME',
  );
  // Product / entitlement IDs — must match RevenueCat dashboard exactly
  static const String arenaMonthlyId = 'nexus_arena_monthly';
  static const String legacyAnnualId = 'nexus_legacy_annual';
  static const String analyzeWeaknessId = 'nexus_analyze_weakness';
  static const String toxicPersonaId = 'nexus_toxic_persona';
  static const String roughManagerPersonaId = 'nexus_rough_manager';
  static const String arenaEntitlement = 'arena_access';
  static const String legacyEntitlement = 'legacy_access';

  // ── Persona ───────────────────────────────────────────────────────────────────
  static const int fractureThreshold = 500;

  // ── Platform Channels ─────────────────────────────────────────────────────────
  static const String hapticChannelName = 'com.example.nexus_app/haptic';
  static const String hapticFractureMethod = 'triggerFractureHaptic';
  static const String hapticArenaMethod = 'triggerArenaHaptic';

  // ── Hive ──────────────────────────────────────────────────────────────────────
  static const String userPrefsBox = 'user_prefs';
  static const String conversationBox = 'conversations';

  // ── Network ───────────────────────────────────────────────────────────────────
  static const Duration llmTimeout = Duration(seconds: 45);
  static const Duration connectTimeout = Duration(seconds: 15);
}
