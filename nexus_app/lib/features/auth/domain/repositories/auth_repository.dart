import 'package:dartz/dartz.dart';
import 'package:nexus_app/core/errors/failures.dart';
import 'package:nexus_app/features/auth/domain/entities/user_entity.dart';

abstract interface class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<Either<AuthFailure, UserEntity>> signInAnonymously();
  Future<Either<AuthFailure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<AuthFailure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<AuthFailure, void>> signOut();
  Future<Either<AuthFailure, UserEntity>> getCurrentUser();
  Future<Either<AuthFailure, void>> incrementInteractionCount(String userId);
}
