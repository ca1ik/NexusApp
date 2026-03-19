import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nexus_app/app/routes/app_routes.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';
import 'package:nexus_app/core/l10n/app_strings.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexus_app/features/conversation/presentation/cubit/conversation_vector_cubit.dart';
import 'package:nexus_app/features/conversation/presentation/cubit/conversation_vector_state.dart';
import 'package:nexus_app/features/monetization/presentation/bloc/monetization_bloc.dart';
import 'package:nexus_app/features/monetization/presentation/bloc/monetization_state.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_bloc.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_event.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_state.dart';
import 'package:nexus_app/features/persona/presentation/widgets/nexus_avatar_widget.dart';
import 'package:nexus_app/features/conversation/domain/entities/message_entity.dart';
import 'package:nexus_app/shared/widgets/glowing_button_widget.dart';
import 'package:shimmer/shimmer.dart';

/// Level 3 — The Arena.
/// Paid subscribers face high-stakes adversarial scenarios.
/// The AI opponent escalates tension, reads weaknesses, mirrors strategy.
class ArenaPage extends StatefulWidget {
  const ArenaPage({super.key});

  @override
  State<ArenaPage> createState() => _ArenaPageState();
}

class _ArenaPageState extends State<ArenaPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext ctx) {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();

    final authState = ctx.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final personaState = ctx.read<PersonaNexusBloc>().state;
    if (personaState is! ArenaSessionActive) return;

    ctx.read<ConversationVectorCubit>().sendMessage(
          userId: authState.user.id,
          content: text,
          persona: personaState.persona,
        );

    ctx.read<PersonaNexusBloc>().add(
          InteractionRecorded(userInput: text, aiResponse: ''),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _requestWeaknessAnalysis(BuildContext ctx) {
    final authState = ctx.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    ctx.read<PersonaNexusBloc>().add(const WeaknessAnalysisRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonaNexusBloc, PersonaNexusState>(
      listener: (ctx, state) {
        if (state is WeaknessAnalysisReady) {
          _showWeaknessBottomSheet(context, state.weaknesses.join('\n\n'));
        }
      },
      child: Scaffold(
        backgroundColor: ThemeConstants.arenaBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              _buildScenarioCard(context),
              _buildTensionMeter(context),
              Expanded(child: _buildMessages(context)),
              _buildBottomControls(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ThemeConstants.textSecondary,
              size: 18,
            ),
            onPressed: () => Get.back<void>(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Text(
            AppStrings.theArena(context),
            style: const TextStyle(
              color: ThemeConstants.arenaAccent,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const Spacer(),
          const NexusAvatarWidget(personaType: PersonaType.shadow, size: 36),
        ],
      ),
    );
  }

  Widget _buildScenarioCard(BuildContext context) {
    return BlocBuilder<PersonaNexusBloc, PersonaNexusState>(
      builder: (ctx, state) {
        if (state is! ArenaSessionActive) return const SizedBox.shrink();
        final scenario = state.scenario;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: ThemeConstants.arenaSurface,
            border: Border.all(color: ThemeConstants.arenaAccent.withAlpha(80)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scenario.title.toUpperCase(),
                style: const TextStyle(
                  color: ThemeConstants.arenaAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                scenario.description,
                style: const TextStyle(
                  color: ThemeConstants.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms);
      },
    );
  }

  Widget _buildTensionMeter(BuildContext context) {
    return BlocBuilder<PersonaNexusBloc, PersonaNexusState>(
      builder: (ctx, state) {
        if (state is! ArenaSessionActive) return const SizedBox.shrink();
        final tension = state.tensionLevel;
        final tensionFraction = tension / 100.0;

        final meterColor = tension >= 80
            ? ThemeConstants.fracturePrimary
            : tension >= 60
                ? ThemeConstants.fractureSecondary
                : ThemeConstants.arenaAccent;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.tension(context),
                    style: TextStyle(
                      color: meterColor,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    '$tension%',
                    style: TextStyle(
                      color: meterColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: tensionFraction,
                backgroundColor: ThemeConstants.arenaSurface,
                valueColor: AlwaysStoppedAnimation<Color>(meterColor),
                minHeight: 4,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessages(BuildContext context) {
    return BlocBuilder<ConversationVectorCubit, ConversationVectorState>(
      builder: (ctx, state) {
        if (state is ConversationLoading) {
          return Center(
            child: Shimmer.fromColors(
              baseColor: ThemeConstants.arenaSurface,
              highlightColor: ThemeConstants.arenaAccent.withAlpha(80),
              child: Container(
                width: 200,
                height: 20,
                decoration: BoxDecoration(
                  color: ThemeConstants.arenaSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }

        if (state is! ConversationLoaded) {
          return Center(
            child: Text(
              AppStrings.selectScenario(context),
              style: const TextStyle(
                color: ThemeConstants.textDisabled,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: state.messages.length + (state.isStreaming ? 1 : 0),
          itemBuilder: (ctx2, i) {
            if (i == state.messages.length && state.isStreaming) {
              return _buildTypingIndicator();
            }
            final msg = state.messages[i];
            final isUser = msg.role == MessageRole.user;
            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                constraints: const BoxConstraints(maxWidth: 280),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isUser
                      ? ThemeConstants.arenaSurface
                      : ThemeConstants.arenaAccent.withAlpha(30),
                  border: Border.all(
                    color: isUser
                        ? ThemeConstants.arenaSurface
                        : ThemeConstants.arenaAccent.withAlpha(80),
                  ),
                ),
                child: Text(
                  msg.content,
                  style: const TextStyle(
                    color: ThemeConstants.textPrimary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideX(begin: isUser ? 0.1 : -0.1);
          },
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ThemeConstants.arenaAccent.withAlpha(30),
          border: Border.all(color: ThemeConstants.arenaAccent.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              width: 6,
              height: 6,
              margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeConstants.arenaAccent,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeOut(
                  delay: Duration(milliseconds: i * 200),
                  duration: 600.ms,
                )
                .then()
                .fadeIn(duration: 600.ms);
          }),
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Weakness analysis — locked unless subscribed
        BlocBuilder<MonetizationBloc, MonetizationState>(
          builder: (ctx, monoState) {
            final hasAccess =
                monoState is OfferingsLoaded ? monoState.hasArenaAccess : false;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: GlowingButtonWidget(
                label: AppStrings.analyzeWeakness(context),
                glowColor: ThemeConstants.arenaAccent,
                isLocked: !hasAccess,
                onTap: hasAccess
                    ? () => _requestWeaknessAnalysis(context)
                    : () => Get.toNamed(AppRoutes.paywall),
              ),
            );
          },
        ),

        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: ThemeConstants.arenaSurface.withAlpha(200),
            border: Border(
              top: BorderSide(color: ThemeConstants.arenaAccent.withAlpha(60)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  style: const TextStyle(color: ThemeConstants.textPrimary),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(context),
                  decoration: InputDecoration(
                    hintText: AppStrings.mountYourArgument(context),
                    hintStyle:
                        const TextStyle(color: ThemeConstants.textDisabled),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _sendMessage(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeConstants.arenaAccent.withAlpha(180),
                    boxShadow: const [
                      BoxShadow(
                        color: ThemeConstants.arenaGlow,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showWeaknessBottomSheet(BuildContext context, String analysis) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ThemeConstants.arenaSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppStrings.weaknessDossier(context),
                  style: const TextStyle(
                    color: ThemeConstants.arenaAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: ThemeConstants.textSecondary,
                    size: 18,
                  ),
                  onPressed: () => Get.back<void>(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              analysis,
              style: const TextStyle(
                color: ThemeConstants.textPrimary,
                fontSize: 14,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
