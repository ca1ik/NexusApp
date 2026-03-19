import 'package:equatable/equatable.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';

sealed class PersonaNexusEvent extends Equatable {
  const PersonaNexusEvent();

  @override
  List<Object?> get props => const [];
}

/// App startup: initialise the Mirror persona for a logged-in user.
final class PersonaInitialized extends PersonaNexusEvent {
  const PersonaInitialized({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Records one completed exchange; may trigger The Fracture automatically.
final class InteractionRecorded extends PersonaNexusEvent {
  const InteractionRecorded({
    required this.userInput,
    required this.aiResponse,
  });

  final String userInput;
  final String aiResponse;

  @override
  List<Object?> get props => [userInput, aiResponse];
}

/// Manually launch the Fracture sequence (e.g. after early-access purchase).
final class FractureInitiated extends PersonaNexusEvent {
  const FractureInitiated();
}

/// User chooses Shadow Nexus on the Fracture screen.
final class ShadowPersonaChosen extends PersonaNexusEvent {
  const ShadowPersonaChosen();
}

/// User chooses Prime Nexus on the Fracture screen.
final class PrimePersonaChosen extends PersonaNexusEvent {
  const PrimePersonaChosen();
}

/// Start an Arena battle with the given scenario and persona.
final class ArenaSessionStarted extends PersonaNexusEvent {
  const ArenaSessionStarted({required this.scenario, required this.personaId});

  final ArenaScenario scenario;
  final String personaId;

  @override
  List<Object?> get props => [scenario.id, personaId];
}

/// Request a weakness analysis (premium feature).
final class WeaknessAnalysisRequested extends PersonaNexusEvent {
  const WeaknessAnalysisRequested();
}

/// Unlock an add-on persona by product ID.
final class PersonaUnlocked extends PersonaNexusEvent {
  const PersonaUnlocked(this.personaId);

  final String personaId;

  @override
  List<Object?> get props => [personaId];
}

/// Return to The Mirror from any state.
final class PersonaReset extends PersonaNexusEvent {
  const PersonaReset();
}
