import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';

/// A glowing, pulsing action button used throughout the Nexus UI.
/// Supports locked state for premium features.
class GlowingButtonWidget extends StatelessWidget {
  const GlowingButtonWidget({
    super.key,
    required this.label,
    required this.glowColor,
    required this.onTap,
    this.isLocked = false,
    this.isLoading = false,
    this.icon,
    this.width = double.infinity,
  });

  final String label;
  final Color glowColor;
  final VoidCallback? onTap;
  final bool isLocked;
  final bool isLoading;
  final IconData? icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isLocked ? ThemeConstants.textDisabled : glowColor;

    return GestureDetector(
          onTap: (isLocked || isLoading) ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: effectiveColor.withAlpha(isLocked ? 60 : 160),
                width: 1.5,
              ),
              boxShadow: isLocked
                  ? null
                  : [
                      BoxShadow(
                        color: effectiveColor.withAlpha(80),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
              gradient: LinearGradient(
                colors: [
                  effectiveColor.withAlpha(isLocked ? 20 : 50),
                  effectiveColor.withAlpha(isLocked ? 10 : 30),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLocked)
                  const Icon(
                    Icons.lock,
                    size: 16,
                    color: ThemeConstants.textDisabled,
                  )
                else if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                      strokeWidth: 2,
                    ),
                  )
                else if (icon != null)
                  Icon(icon, size: 18, color: effectiveColor),
                if ((isLocked || isLoading || icon != null))
                  const SizedBox(width: 8),
                Text(
                  isLocked ? '🔒  $label' : label,
                  style: TextStyle(
                    color: effectiveColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(onPlay: isLocked ? null : (c) => c.repeat(reverse: true))
        .shimmer(
          duration: const Duration(milliseconds: 2500),
          color: effectiveColor.withAlpha(30),
        );
  }
}
