import 'package:equatable/equatable.dart';

// ── Failure hierarchy ─────────────────────────────────────────────────────────
sealed class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

final class LlmFailure extends Failure {
  const LlmFailure({required super.message});
}

final class VectorDbFailure extends Failure {
  const VectorDbFailure({required super.message});
}

final class MonetizationFailure extends Failure {
  const MonetizationFailure({required super.message});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

final class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}
