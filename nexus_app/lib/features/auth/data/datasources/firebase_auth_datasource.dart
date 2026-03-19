import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus_app/core/errors/exceptions.dart';
import 'package:nexus_app/features/auth/domain/entities/user_entity.dart';

abstract interface class FirebaseAuthDataSource {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity> signInAnonymously();
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<UserEntity> getCurrentUser();
  Future<void> incrementInteractionCount(String userId);
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  FirebaseAuthDataSourceImpl({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<UserEntity?> get authStateChanges => _auth.authStateChanges().asyncMap(
        (u) async => u == null ? null : _resolveUser(u),
      );

  @override
  Future<UserEntity> signInAnonymously() async {
    try {
      final cred = await _auth.signInAnonymously();
      return _resolveUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Anonymous sign-in failed');
    }
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _resolveUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign-in failed');
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _resolveUser(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign-up failed');
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException(message: 'No authenticated user');
    }
    return _resolveUser(user);
  }

  @override
  Future<void> incrementInteractionCount(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'interactionCount': FieldValue.increment(1),
    });
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  Future<UserEntity> _resolveUser(User fbUser) async {
    final snap = await _firestore.collection('users').doc(fbUser.uid).get();
    if (snap.exists) {
      return _fromFirestore(fbUser.uid, snap.data()!);
    }
    // First sign-in — create the Firestore document
    final now = DateTime.now();
    final data = <String, dynamic>{
      'email': fbUser.email ?? '',
      'displayName': fbUser.displayName ?? 'Seeker',
      'interactionCount': 0,
      'unlockedPersonaIds': <String>[],
      'hasArenaAccess': false,
      'hasLegacyAccess': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('users').doc(fbUser.uid).set(data);
    return UserEntity(
      id: fbUser.uid,
      email: fbUser.email ?? '',
      displayName: fbUser.displayName ?? 'Seeker',
      interactionCount: 0,
      unlockedPersonaIds: const [],
      hasArenaAccess: false,
      hasLegacyAccess: false,
      createdAt: now,
    );
  }

  UserEntity _fromFirestore(String uid, Map<String, dynamic> d) => UserEntity(
        id: uid,
        email: d['email'] as String? ?? '',
        displayName: d['displayName'] as String? ?? 'Seeker',
        interactionCount: d['interactionCount'] as int? ?? 0,
        unlockedPersonaIds: List<String>.from(
          d['unlockedPersonaIds'] as List? ?? [],
        ),
        hasArenaAccess: d['hasArenaAccess'] as bool? ?? false,
        hasLegacyAccess: d['hasLegacyAccess'] as bool? ?? false,
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
