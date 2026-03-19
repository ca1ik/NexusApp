import 'package:equatable/equatable.dart';
import 'package:nexus_app/features/auth/domain/entities/user_entity.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';

sealed class PersonaNexusState extends Equatable {
  const PersonaNexusState();

  @override
  List<Object?> get props => const [];
}

/// Before the user's first interaction.
final class PersonaNexusInitial extends PersonaNexusState {
  const PersonaNexusInitial();
}

final class PersonaNexusLoading extends PersonaNexusState {
  const PersonaNexusLoading();
}

/// Level 1 — The Mirror is active, probing the user.
final class MirrorActive extends PersonaNexusState {
  const MirrorActive({
    required this.user,
    required this.persona,
    required this.currentQuestion,
    required this.interactionCount,
  });

  final UserEntity user;
  final PersonaEntity persona;
  final String currentQuestion;
  final int interactionCount;

  /// Progress towards The Fracture (0.0 → 1.0).
  double get fractureProgress => (interactionCount / 500).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [user, persona, currentQuestion, interactionCount];
}

/// The cinematic split — Shadow vs Prime choice screen.
final class FractureTriggered extends PersonaNexusState {
  const FractureTriggered({
    required this.user,
    required this.shadowPersona,
    required this.primePersona,
  });

  final UserEntity user;
  final PersonaEntity shadowPersona;
  final PersonaEntity primePersona;

  @override
  List<Object?> get props => [user, shadowPersona, primePersona];
}

/// Shadow Nexus is active — adversarial / stress-test mode.
final class ShadowNexusActive extends PersonaNexusState {
  const ShadowNexusActive({
    required this.user,
    required this.persona,
    this.latestInsight = '',
  });

  final UserEntity user;
  final PersonaEntity persona;
  final String latestInsight;

  @override
  List<Object?> get props => [user, persona, latestInsight];
}

/// Prime Nexus is active — ally / amplification mode.
final class PrimeNexusActive extends PersonaNexusState {
  const PrimeNexusActive({
    required this.user,
    required this.persona,
    this.latestInsight = '',
  });

  final UserEntity user;
  final PersonaEntity persona;
  final String latestInsight;

  @override
  List<Object?> get props => [user, persona, latestInsight];
}

/// Arena of Minds — battle or alliance simulation session.
final class ArenaSessionActive extends PersonaNexusState {
  const ArenaSessionActive({
    required this.user,
    required this.persona,
    required this.scenario,
    this.tensionLevel = 0,
  });

  final UserEntity user;
  final PersonaEntity persona;
  final ArenaScenario scenario;

  /// 0–100: rises as the conversation intensifies.
  final int tensionLevel;

  @override
  List<Object?> get props => [user, persona, scenario.id, tensionLevel];
}

/// Premium weakness analysis has been computed.
final class WeaknessAnalysisReady extends PersonaNexusState {
  const WeaknessAnalysisReady({
    required this.weaknesses,
    required this.previousState,
  });

  final List<String> weaknesses;
  final PersonaNexusState previousState;

  @override
  List<Object?> get props => [weaknesses];
}

final class PersonaNexusError extends PersonaNexusState {
  const PersonaNexusError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
