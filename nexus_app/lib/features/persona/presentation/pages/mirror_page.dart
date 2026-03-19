import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nexus_app/app/routes/app_routes.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:nexus_app/features/conversation/presentation/cubit/conversation_vector_cubit.dart';
import 'package:nexus_app/features/conversation/presentation/cubit/conversation_vector_state.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_bloc.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_event.dart';
import 'package:nexus_app/features/persona/presentation/bloc/persona_nexus_state.dart';
import 'package:nexus_app/features/conversation/domain/entities/message_entity.dart';
import 'package:nexus_app/features/persona/presentation/widgets/nexus_avatar_widget.dart';
import 'package:shimmer/shimmer.dart';

/// Level 1 — The Mirror.
/// The persona silently absorbs the user's patterns through probing philosophy.
class MirrorPage extends StatefulWidget {
  const MirrorPage({super.key});

  @override
  State<MirrorPage> createState() => _MirrorPageState();
}

class _MirrorPageState extends State<MirrorPage> {
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
    PersonaEntity persona;
    if (personaState is MirrorActive) {
      persona = personaState.persona;
    } else {
      return;
    }

    ctx.read<ConversationVectorCubit>().sendMessage(
          userId: authState.user.id,
          content: text,
          persona: persona,
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonaNexusBloc, PersonaNexusState>(
      listener: (ctx, state) {
        if (state is FractureTriggered) {
          Get.toNamed(AppRoutes.fracture);
        }
      },
      child: Scaffold(
        backgroundColor: ThemeConstants.mirrorBg,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(child: _buildContent(context)),
              _buildInputBar(context),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'THE MIRROR',
            style: TextStyle(
              color: ThemeConstants.mirrorAccent,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          BlocBuilder<PersonaNexusBloc, PersonaNexusState>(
            builder: (ctx, state) {
              if (state is MirrorActive) {
                final progress = state.fractureProgress;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${state.interactionCount} / 500',
                      style: const TextStyle(
                        color: ThemeConstants.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 80,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: ThemeConstants.mirrorSurface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.8
                              ? ThemeConstants.fractureSecondary
                              : ThemeConstants.mirrorPrimary,
                        ),
                        minHeight: 3,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<PersonaNexusBloc, PersonaNexusState>(
      builder: (ctx, personaState) {
        return BlocBuilder<ConversationVectorCubit, ConversationVectorState>(
          builder: (ctx2, convState) {
            final isLoading = convState is ConversationLoading ||
                (convState is ConversationLoaded && convState.isStreaming);

            return Column(
              children: [
                const SizedBox(height: 24),

                // Avatar
                NexusAvatarWidget(
                  personaType: PersonaType.mirror,
                  isLoading: isLoading,
                ).animate().fadeIn(duration: const Duration(seconds: 1)),

                const SizedBox(height: 32),

                // Current question / response
                if (personaState is MirrorActive)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: isLoading
                        ? Shimmer.fromColors(
                            baseColor: ThemeConstants.mirrorSurface,
                            highlightColor:
                                ThemeConstants.mirrorPrimary.withAlpha(120),
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: ThemeConstants.mirrorSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          )
                        : Text(
                            personaState.currentQuestion,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: ThemeConstants.textPrimary,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                            ),
                          ).animate().fadeIn(duration: 600.ms),
                  ),

                // Message history
                Expanded(
                  child: convState is ConversationLoaded &&
                          convState.messages.isNotEmpty
                      ? ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: convState.messages.length,
                          itemBuilder: (ctx3, i) {
                            final msg = convState.messages[i];
                            final isUser = msg.role == MessageRole.user;
                            return Align(
                              alignment: isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                constraints: const BoxConstraints(
                                  maxWidth: 280,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: isUser
                                      ? ThemeConstants.mirrorSurface
                                      : ThemeConstants.mirrorPrimary
                                          .withAlpha(40),
                                  border: Border.all(
                                    color: isUser
                                        ? ThemeConstants.mirrorSurface
                                        : ThemeConstants.mirrorPrimary
                                            .withAlpha(80),
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
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: ThemeConstants.mirrorSurface.withAlpha(200),
        border: Border(
          top: BorderSide(color: ThemeConstants.mirrorPrimary.withAlpha(60)),
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
              decoration: const InputDecoration(
                hintText: 'Speak your truth...',
                hintStyle: TextStyle(color: ThemeConstants.textDisabled),
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
                color: ThemeConstants.mirrorPrimary.withAlpha(180),
                boxShadow: const [
                  BoxShadow(color: ThemeConstants.mirrorGlow, blurRadius: 12),
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
    );
  }
}
