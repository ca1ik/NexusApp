import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexus_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _repo = authRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<SignInAnonymouslyRequested>(_onSignInAnonymously);
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<SignUpWithEmailRequested>(_onSignUpWithEmail);
    on<SignOutRequested>(_onSignOut);
  }

  final AuthRepository _repo;

  Future<void> _onAuthCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await emit.forEach(
      _repo.authStateChanges,
      onData: (user) =>
          user != null ? AuthAuthenticated(user) : const AuthUnauthenticated(),
      onError: (_, __) => const AuthUnauthenticated(),
    );
  }

  Future<void> _onSignInAnonymously(
    SignInAnonymouslyRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repo.signInAnonymously();
    result.fold(
      (f) => emit(AuthError(f.message)),
      (u) => emit(AuthAuthenticated(u)),
    );
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repo.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (f) => emit(AuthError(f.message)),
      (u) => emit(AuthAuthenticated(u)),
    );
  }

  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repo.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repo.signUpWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (f) => emit(AuthError(f.message)),
      (u) => emit(AuthAuthenticated(u)),
    );
  }
}
