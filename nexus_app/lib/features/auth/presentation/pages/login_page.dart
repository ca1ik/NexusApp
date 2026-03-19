import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nexus_app/app/routes/app_routes.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexus_app/shared/widgets/glowing_button_widget.dart';

/// Login page — "Enter as a Seeker" (anonymous) or email sign-in.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showEmailForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthAuthenticated) {
          Get.offAllNamed(AppRoutes.mirror);
        } else if (state is AuthError) {
          Get.snackbar(
            'Access Denied',
            state.message,
            backgroundColor: ThemeConstants.fracturePrimary.withAlpha(200),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
      child: Scaffold(
        backgroundColor: ThemeConstants.mirrorBg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),

                // Title
                const Text(
                  'THE NEXUS\nOF POWER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeConstants.mirrorAccent,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                    height: 1.2,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),

                const SizedBox(height: 16),
                const Text(
                  '"Create your best version.\nBattle it. Or ally with it."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeConstants.textSecondary,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 800.ms),

                const SizedBox(height: 60),

                // Orb
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ThemeConstants.mirrorPrimary,
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeConstants.mirrorGlow,
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(
                    begin: 0.88,
                    end: 1.12,
                    duration: const Duration(seconds: 3),),

                const SizedBox(height: 64),

                // Anonymous entry
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (ctx, state) {
                    final isLoading = state is AuthLoading;
                    return Column(
                      children: [
                        GlowingButtonWidget(
                          label: 'ENTER AS A SEEKER',
                          glowColor: ThemeConstants.mirrorPrimary,
                          isLoading: isLoading,
                          onTap: () => ctx.read<AuthBloc>().add(
                                const SignInAnonymouslyRequested(),
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              setState(() => _showEmailForm = !_showEmailForm),
                          child: Text(
                            _showEmailForm
                                ? 'HIDE SIGN IN'
                                : 'SIGN IN WITH EMAIL',
                            style: const TextStyle(
                              color: ThemeConstants.mirrorAccent,
                              letterSpacing: 1.5,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (_showEmailForm) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(
                              color: ThemeConstants.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: ThemeConstants.mirrorPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(
                              color: ThemeConstants.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: ThemeConstants.mirrorPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GlowingButtonWidget(
                            label: 'ENTER',
                            glowColor: ThemeConstants.mirrorSecondary,
                            isLoading: isLoading,
                            onTap: () => ctx.read<AuthBloc>().add(
                                  SignInWithEmailRequested(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  ),
                                ),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 40),
                const Text(
                  'Your journey into the self begins here.',
                  style: TextStyle(
                    color: ThemeConstants.textDisabled,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 1200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
