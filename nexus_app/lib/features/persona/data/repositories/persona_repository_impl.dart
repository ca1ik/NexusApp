import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';
import 'package:nexus_app/features/persona/domain/repositories/persona_repository.dart';

class PersonaRepositoryImpl implements PersonaRepository {
  static final Map<String, PersonaEntity> _addOns = {
    'rough_manager': PersonaEntity.roughManagerPersona(),
  };

  @override
  PersonaEntity getMirrorPersona() => PersonaEntity.mirror();

  @override
  PersonaEntity getShadowPersona() => PersonaEntity.shadow();

  @override
  PersonaEntity getPrimePersona() => PersonaEntity.prime();

  @override
  PersonaEntity? getUnlockedPersona(String id) => _addOns[id];

  @override
  List<PersonaEntity> getAllPersonas({List<String> unlockedIds = const []}) => [
    getMirrorPersona(),
    getShadowPersona(),
    getPrimePersona(),
    ..._addOns.entries
        .where((e) => unlockedIds.contains(e.key))
        .map((e) => e.value),
  ];
}
