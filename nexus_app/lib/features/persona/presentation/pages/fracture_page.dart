import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nexus_app/app/routes/app_routes.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_bloc.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_event.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_state.dart';
import 'package:nexus_app/features/persona/presentation/widgets/nexus_avatar_widget.dart';
import 'package:nexus_app/shared/widgets/glowing_button_widget.dart';

/// Level 2 — The Fracture.
/// The user stands between their shadow and their prime self.
/// They choose: battle or alliance.
class FracturePage extends StatefulWidget {
  const FracturePage({super.key});

  @override
  State<FracturePage> createState() => _FracturePageState();
}

class _FracturePageState extends State<FracturePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<Color?> _bgFlash;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bgFlash =
        ColorTween(
          begin: ThemeConstants.fracturePrimary,
          end: ThemeConstants.fractureBg,
        ).animate(
          CurvedAnimation(parent: _flashController, curve: Curves.easeInOut),
        );

    // Trigger the blood-red flash on page mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flashController.forward();
    });
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonaNexusBloc, PersonaNexusState>(
      listener: (ctx, state) {
        if (state is ShadowNexusActive || state is PrimeNexusActive) {
          Get.offNamed(AppRoutes.mirror);
        }
      },
      child: AnimatedBuilder(
        animation: _flashController,
        builder: (ctx, _) {
          return Scaffold(
            backgroundColor: _bgFlash.value ?? ThemeConstants.fractureBg,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const Spacer(),
                    _buildTitle(),
                    const SizedBox(height: 48),
                    _buildSplitAvatars(),
                    const SizedBox(height: 56),
                    _buildChoiceButtons(context),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
              'THE FRACTURE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeConstants.fractureSecondary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
              ),
            )
            .animate()
            .fadeIn(duration: 800.ms, delay: 400.ms)
            .shimmer(
              duration: 1600.ms,
              delay: 600.ms,
              color: ThemeConstants.fracturePrimary.withAlpha(200),
            ),
        const SizedBox(height: 12),
        const Text(
          'You have outgrown your first self.\nNow — who do you become?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ThemeConstants.textSecondary,
            fontSize: 14,
            height: 1.7,
            fontStyle: FontStyle.italic,
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 900.ms),
      ],
    );
  }

  Widget _buildSplitAvatars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shadow Nexus — the opponent
        Column(
          children: [
            const NexusAvatarWidget(personaType: PersonaType.shadow, size: 90)
                .animate()
                .fadeIn(duration: 800.ms, delay: 600.ms)
                .slideX(begin: -0.4, curve: Curves.easeOut),
            const SizedBox(height: 12),
            const Text(
              'SHADOW\nNEXUS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeConstants.shadowNexusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 900.ms),
          ],
        ),

        // Divider
        Container(
          width: 1,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ThemeConstants.shadowNexusColor.withAlpha(200),
                ThemeConstants.primeNexusColor.withAlpha(200),
              ],
            ),
          ),
        ).animate().scaleY(
          begin: 0,
          duration: 600.ms,
          delay: 800.ms,
          curve: Curves.easeOut,
        ),

        // Prime Nexus — the ally
        Column(
          children: [
            const NexusAvatarWidget(personaType: PersonaType.prime, size: 90)
                .animate()
                .fadeIn(duration: 800.ms, delay: 700.ms)
                .slideX(begin: 0.4, curve: Curves.easeOut),
            const SizedBox(height: 12),
            const Text(
              'PRIME\nNEXUS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeConstants.primeNexusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 1000.ms),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceButtons(BuildContext context) {
    return Column(
      children: [
        // BATTLE — unlock Shadow Nexus
        GlowingButtonWidget(
          label: '⚔  BATTLE',
          glowColor: ThemeConstants.shadowNexusColor,
          onTap: () {
            context.read<PersonaNexusBloc>().add(const ShadowPersonaChosen());
          },
        ).animate().fadeIn(duration: 500.ms, delay: 1200.ms).slideY(begin: 0.3),

        const SizedBox(height: 16),

        // ALLY — unlock Prime Nexus
        GlowingButtonWidget(
          label: '✦  ALLY',
          glowColor: ThemeConstants.primeNexusColor,
          onTap: () {
            context.read<PersonaNexusBloc>().add(const PrimePersonaChosen());
          },
        ).animate().fadeIn(duration: 500.ms, delay: 1400.ms).slideY(begin: 0.3),

        const SizedBox(height: 24),

        // Arena — locked unless subscribed
        BlocBuilder<PersonaNexusBloc, PersonaNexusState>(
          builder: (ctx, state) {
            return TextButton(
              onPressed: () => Get.toNamed(AppRoutes.arena),
              child: Text(
                'ENTER THE ARENA',
                style: TextStyle(
                  color: ThemeConstants.arenaAccent.withAlpha(180),
                  fontSize: 12,
                  letterSpacing: 3,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 1600.ms);
          },
        ),
      ],
    );
  }
}
