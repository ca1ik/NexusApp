import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';

abstract interface class PersonaRepository {
  /// Returns the Mirror persona (always available).
  PersonaEntity getMirrorPersona();

  /// Returns Shadow Nexus (unlocked after fracture).
  PersonaEntity getShadowPersona();

  /// Returns Prime Nexus (unlocked after fracture).
  PersonaEntity getPrimePersona();

  /// Returns a locked add-on persona by [id], or null if not found.
  PersonaEntity? getUnlockedPersona(String id);

  /// All built-in personas (mirror, shadow, prime + any unlocked add-ons).
  List<PersonaEntity> getAllPersonas({List<String> unlockedIds = const []});
}
