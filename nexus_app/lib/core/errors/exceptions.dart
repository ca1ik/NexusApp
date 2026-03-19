// ── Exception hierarchy (datasource layer) ───────────────────────────────────
class AppException implements Exception {
  const AppException({required this.message});

  final String message;

  @override
  String toString() => 'AppException($message)';
}

class AuthException extends AppException {
  const AuthException({required super.message});
}

class LlmException extends AppException {
  const LlmException({required super.message});
}

class VectorDbException extends AppException {
  const VectorDbException({required super.message});
}

class MonetizationException extends AppException {
  const MonetizationException({required super.message});
}

class CacheException extends AppException {
  const CacheException({required super.message});
}
