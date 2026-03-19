import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nexus_app/core/l10n/locale_provider.dart';
import 'package:nexus_app/core/network/api_client.dart';
import 'package:nexus_app/core/platform/haptic_channel.dart';
import 'package:nexus_app/core/theme/theme_provider.dart';
import 'package:nexus_app/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:nexus_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nexus_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexus_app/features/conversation/data/datasources/llm_datasource.dart';
import 'package:nexus_app/features/conversation/data/datasources/vector_db_datasource.dart';
import 'package:nexus_app/features/conversation/data/repositories/conversation_repository_impl.dart';
import 'package:nexus_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:nexus_app/features/conversation/presentation/cubit/conversation_vector_cubit.dart';
import 'package:nexus_app/features/monetization/data/repositories/revenue_cat_repository_impl.dart';
import 'package:nexus_app/features/monetization/domain/repositories/monetization_repository.dart';
import 'package:nexus_app/features/monetization/presentation/bloc/monetization_bloc.dart';
import 'package:nexus_app/features/persona/data/repositories/persona_repository_impl.dart';
import 'package:nexus_app/features/persona/domain/repositories/persona_repository.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_bloc.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  final log = Logger(printer: PrettyPrinter(methodCount: 0));

  getIt
    // ── Infrastructure ──────────────────────────────────────────────────────
    ..registerLazySingleton<Logger>(() => log)
    ..registerLazySingleton<NexusApiClient>(
      () => NexusApiClient(logger: getIt<Logger>()),
    )
    ..registerLazySingleton<NexusHapticChannel>(
      () => NexusHapticChannel(logger: getIt<Logger>()),
    )
    // ── Theme ───────────────────────────────────────────────────────────────
    ..registerLazySingleton<NexusThemeProvider>(() => NexusThemeProvider())
    // ── Locale ──────────────────────────────────────────────────────────────
    ..registerLazySingleton<NexusLocaleProvider>(() => NexusLocaleProvider())
    // ── Auth ────────────────────────────────────────────────────────────────
    ..registerLazySingleton<FirebaseAuthDataSource>(
      () => FirebaseAuthDataSourceImpl(),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(dataSource: getIt<FirebaseAuthDataSource>()),
    )
    ..registerFactory<AuthBloc>(
      () => AuthBloc(authRepository: getIt<AuthRepository>()),
    )
    // ── Persona ─────────────────────────────────────────────────────────────
    ..registerLazySingleton<PersonaRepository>(() => PersonaRepositoryImpl())
    ..registerFactory<PersonaNexusBloc>(
      () => PersonaNexusBloc(
        personaRepository: getIt<PersonaRepository>(),
        themeProvider: getIt<NexusThemeProvider>(),
        hapticChannel: getIt<NexusHapticChannel>(),
      ),
    )
    // ── Conversation ─────────────────────────────────────────────────────────
    ..registerLazySingleton<LlmDataSource>(
      () => LlmDataSourceImpl(apiClient: getIt<NexusApiClient>()),
    )
    ..registerLazySingleton<VectorDbDataSource>(
      () => VectorDbDataSourceImpl(apiClient: getIt<NexusApiClient>()),
    )
    ..registerLazySingleton<ConversationRepository>(
      () => ConversationRepositoryImpl(
        llmDataSource: getIt<LlmDataSource>(),
        vectorDbDataSource: getIt<VectorDbDataSource>(),
      ),
    )
    ..registerFactory<ConversationVectorCubit>(
      () =>
          ConversationVectorCubit(repository: getIt<ConversationRepository>()),
    )
    // ── Monetization ─────────────────────────────────────────────────────────
    ..registerLazySingleton<MonetizationRepository>(
      () => RevenueCatRepositoryImpl(logger: getIt<Logger>()),
    )
    ..registerFactory<MonetizationBloc>(
      () => MonetizationBloc(
        monetizationRepository: getIt<MonetizationRepository>(),
      ),
    );
}
