import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';
import 'package:nexus_app/features/persona/domain/entities/persona_entity.dart';

/// The living avatar representing the active Nexus persona.
/// Pulses, glows, and reacts to persona type changes.
class NexusAvatarWidget extends StatefulWidget {
  const NexusAvatarWidget({
    super.key,
    required this.personaType,
    this.size = 180,
    this.isLoading = false,
  });

  final PersonaType personaType;
  final double size;
  final bool isLoading;

  @override
  State<NexusAvatarWidget> createState() => _NexusAvatarWidgetState();
}

class _NexusAvatarWidgetState extends State<NexusAvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _primaryColor => switch (widget.personaType) {
    PersonaType.mirror => ThemeConstants.mirrorPrimary,
    PersonaType.shadow => ThemeConstants.shadowNexusColor,
    PersonaType.prime => ThemeConstants.primeNexusColor,
  };

  Color get _glowColor => switch (widget.personaType) {
    PersonaType.mirror => ThemeConstants.mirrorGlow,
    PersonaType.shadow => ThemeConstants.fractureGlow,
    PersonaType.prime => const Color(0x4400B0FF),
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
          animation: _pulseController,
          builder: (ctx, child) {
            final pulse = 0.9 + (_pulseController.value * 0.1);
            return Transform.scale(scale: pulse, child: child);
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _primaryColor.withAlpha(200),
                  _primaryColor.withAlpha(80),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: _glowColor,
                  blurRadius: widget.size * 0.5,
                  spreadRadius: widget.size * 0.05,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inner crystalline core
                Container(
                  width: widget.size * 0.4,
                  height: widget.size * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primaryColor.withAlpha(160),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor,
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),

                // Fracture lines for shadow/prime
                if (widget.personaType != PersonaType.mirror)
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _FractureLinePainter(color: _primaryColor),
                  ),

                // Loading shimmer ring
                if (widget.isLoading)
                  SizedBox(
                    width: widget.size * 0.9,
                    height: widget.size * 0.9,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                      strokeWidth: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: const Duration(milliseconds: 3000),
          color: _primaryColor.withAlpha(40),
        );
  }
}

class _FractureLinePainter extends CustomPainter {
  const _FractureLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(120)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    // Three jagged fracture lines emanating from center
    final offsets = [
      [0.0, -r, r * 0.4, -r * 0.5],
      [-r * 0.7, r * 0.5, -r * 0.2, r * 0.9],
      [r * 0.6, r * 0.3, r * 0.9, -r * 0.3],
    ];

    for (final o in offsets) {
      final path = Path()
        ..moveTo(cx, cy)
        ..lineTo(cx + o[0], cy + o[1])
        ..lineTo(cx + o[2], cy + o[3]);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_FractureLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
