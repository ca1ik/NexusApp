import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:get/get.dart';
import 'package:nexus_app/app/routes/app_pages.dart';
import 'package:nexus_app/app/routes/app_routes.dart';
import 'package:nexus_app/core/di/injection.dart';
import 'package:nexus_app/core/theme/theme_provider.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:nexus_app/features/conversation/presentation/cubit/conversation_vector_cubit.dart';
import 'package:nexus_app/features/monetization/presentation/bloc/monetization_bloc.dart';
import 'package:nexus_app/features/monetization/presentation/bloc/monetization_event.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_bloc.dart';
import 'package:provider/provider.dart';

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NexusThemeProvider>(
      create: (_) => getIt<NexusThemeProvider>(),
      child: Consumer<NexusThemeProvider>(
        builder: (_, themeProvider, __) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
            ),
            BlocProvider<PersonaNexusBloc>(
              create: (_) => getIt<PersonaNexusBloc>(),
            ),
            BlocProvider<ConversationVectorCubit>(
              create: (_) => getIt<ConversationVectorCubit>(),
            ),
            BlocProvider<MonetizationBloc>(
              create: (_) =>
                  getIt<MonetizationBloc>()..add(const LoadOfferings()),
            ),
          ],
          child: GetMaterialApp(
            title: 'The Nexus of Power',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            initialRoute: AppRoutes.splash,
            getPages: AppPages.routes,
            defaultTransition: Transition.fadeIn,
            transitionDuration: const Duration(milliseconds: 600),
          ),
        ),
      ),
    );
  }
}
