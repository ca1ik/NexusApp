import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

final class SignInAnonymouslyRequested extends AuthEvent {
  const SignInAnonymouslyRequested();
}

final class SignInWithEmailRequested extends AuthEvent {
  const SignInWithEmailRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}
