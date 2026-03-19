import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:nexus_app/app/routes/app_routes.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';
import 'package:nexus_app/core/l10n/app_strings.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_bloc.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_event.dart';

/// Splash screen: checks auth state and routes accordingly.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthAuthenticated) {
          ctx.read<PersonaNexusBloc>().add(
                PersonaInitialized(userId: state.user.id),
              );
          Get.offNamed(AppRoutes.mirror);
        } else if (state is AuthUnauthenticated) {
          Get.offNamed(AppRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: ThemeConstants.mirrorBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo glow
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ThemeConstants.mirrorPrimary,
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.all_inclusive,
                  size: 56,
                  color: ThemeConstants.mirrorAccent,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
                    begin: 0.92,
                    end: 1.08,
                    duration: const Duration(seconds: 2),
                  ),
              const SizedBox(height: 32),
              Text(
                AppStrings.nexusOfPower(context),
                style: const TextStyle(
                  color: ThemeConstants.mirrorAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 800.ms),
              const SizedBox(height: 8),
              Text(
                AppStrings.initializing(context),
                style: const TextStyle(
                  color: ThemeConstants.textSecondary,
                  fontSize: 12,
                  letterSpacing: 3,
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
