import 'package:mockito/annotations.dart';
import 'package:nexus_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:nexus_app/features/monetization/domain/repositories/monetization_repository.dart';
import 'package:nexus_app/features/persona/domain/repositories/persona_repository.dart';
import 'package:nexus_app/core/theme/theme_provider.dart';
import 'package:nexus_app/core/platform/haptic_channel.dart';

@GenerateMocks([
  ConversationRepository,
  PersonaRepository,
  MonetizationRepository,
  NexusThemeProvider,
  NexusHapticChannel,
])
void main() {}
