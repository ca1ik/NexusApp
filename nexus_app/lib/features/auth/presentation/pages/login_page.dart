import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nexus_app/app/routes/app_routes.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';
import 'package:nexus_app/core/l10n/app_strings.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexus_app/shared/widgets/glowing_button_widget.dart';

/// Login page — guest entry, email sign-in, or sign-up.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showEmailForm = false;
  bool _isSignUpMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            AppStrings.accessDenied(context),
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
                Text(
                  AppStrings.appTitle(context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ThemeConstants.mirrorAccent,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6,
                    height: 1.2,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),

                const SizedBox(height: 16),
                Text(
                  AppStrings.appTagline(context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                      duration: const Duration(seconds: 3),
                    ),

                const SizedBox(height: 64),

                // Auth buttons
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (ctx, state) {
                    final isLoading = state is AuthLoading;
                    return Column(
                      children: [
                        // Guest entry
                        GlowingButtonWidget(
                          label: AppStrings.enterAsGuest(context),
                          glowColor: ThemeConstants.mirrorPrimary,
                          isLoading: isLoading,
                          onTap: () => ctx.read<AuthBloc>().add(
                                const SignInAnonymouslyRequested(),
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() {
                            _showEmailForm = !_showEmailForm;
                            if (!_showEmailForm) _isSignUpMode = false;
                          }),
                          child: Text(
                            _showEmailForm
                                ? AppStrings.hideSignIn(context)
                                : AppStrings.signInWithEmail(context),
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
                            decoration: InputDecoration(
                              hintText: AppStrings.email(context),
                              prefixIcon: const Icon(
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
                            decoration: InputDecoration(
                              hintText: AppStrings.password(context),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: ThemeConstants.mirrorPrimary,
                              ),
                            ),
                          ),
                          if (_isSignUpMode) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              style: const TextStyle(
                                color: ThemeConstants.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: AppStrings.confirmPassword(context),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: ThemeConstants.mirrorPrimary,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          GlowingButtonWidget(
                            label: _isSignUpMode
                                ? AppStrings.signUp(context)
                                : AppStrings.signIn(context),
                            glowColor: ThemeConstants.mirrorSecondary,
                            isLoading: isLoading,
                            onTap: () {
                              if (_isSignUpMode) {
                                if (_passwordController.text !=
                                    _confirmPasswordController.text) {
                                  Get.snackbar(
                                    AppStrings.accessDenied(context),
                                    AppStrings.passwordsDoNotMatch(context),
                                    backgroundColor: ThemeConstants
                                        .fracturePrimary
                                        .withAlpha(200),
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }
                                ctx.read<AuthBloc>().add(
                                      SignUpWithEmailRequested(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                      ),
                                    );
                              } else {
                                ctx.read<AuthBloc>().add(
                                      SignInWithEmailRequested(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                      ),
                                    );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () =>
                                setState(() => _isSignUpMode = !_isSignUpMode),
                            child: Text(
                              _isSignUpMode
                                  ? AppStrings.alreadyHaveAccount(context)
                                  : AppStrings.noAccount(context),
                              style: const TextStyle(
                                color: ThemeConstants.textSecondary,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: 40),
                Text(
                  AppStrings.journeyBegins(context),
                  style: const TextStyle(
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
