import 'package:dartz/dartz.dart';
import 'package:nexus_app/core/errors/exceptions.dart';
import 'package:nexus_app/core/errors/failures.dart';
import 'package:nexus_app/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:nexus_app/features/auth/domain/entities/user_entity.dart';
import 'package:nexus_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required FirebaseAuthDataSource dataSource})
      : _ds = dataSource;

  final FirebaseAuthDataSource _ds;

  @override
  Stream<UserEntity?> get authStateChanges => _ds.authStateChanges;

  @override
  Future<Either<AuthFailure, UserEntity>> signInAnonymously() =>
      _attempt(_ds.signInAnonymously);

  @override
  Future<Either<AuthFailure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _attempt(
        () => _ds.signInWithEmailAndPassword(email: email, password: password),
      );

  @override
  Future<Either<AuthFailure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _attempt(
        () => _ds.signUpWithEmailAndPassword(email: email, password: password),
      );

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      await _ds.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> getCurrentUser() =>
      _attempt(_ds.getCurrentUser);

  @override
  Future<Either<AuthFailure, void>> incrementInteractionCount(
    String userId,
  ) async {
    try {
      await _ds.incrementInteractionCount(userId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }

  Future<Either<AuthFailure, UserEntity>> _attempt(
    Future<UserEntity> Function() fn,
  ) async {
    try {
      return Right(await fn());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }
}
