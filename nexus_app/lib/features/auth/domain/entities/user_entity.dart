import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.interactionCount,
    required this.unlockedPersonaIds,
    required this.hasArenaAccess,
    required this.hasLegacyAccess,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String displayName;
  final int interactionCount;
  final List<String> unlockedPersonaIds;
  final bool hasArenaAccess;
  final bool hasLegacyAccess;
  final DateTime createdAt;

  /// True when the user has earned or purchased The Fracture.
  bool get hasFractureUnlocked => interactionCount >= 500 || hasArenaAccess;

  UserEntity copyWith({
    int? interactionCount,
    List<String>? unlockedPersonaIds,
    bool? hasArenaAccess,
    bool? hasLegacyAccess,
  }) => UserEntity(
    id: id,
    email: email,
    displayName: displayName,
    interactionCount: interactionCount ?? this.interactionCount,
    unlockedPersonaIds: unlockedPersonaIds ?? this.unlockedPersonaIds,
    hasArenaAccess: hasArenaAccess ?? this.hasArenaAccess,
    hasLegacyAccess: hasLegacyAccess ?? this.hasLegacyAccess,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    interactionCount,
    unlockedPersonaIds,
    hasArenaAccess,
    hasLegacyAccess,
    createdAt,
  ];
}
