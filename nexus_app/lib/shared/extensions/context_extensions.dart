import 'package:flutter/material.dart';
import 'package:nexus_app/core/theme/app_theme.dart';
import 'package:nexus_app/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

/// Convenience extension on [BuildContext] for common lookups.
extension NexusContextX on BuildContext {
  /// Current media query data — shorthand to avoid repeated `MediaQuery.of(context)`.
  MediaQueryData get mq => MediaQuery.of(this);

  double get screenWidth => mq.size.width;
  double get screenHeight => mq.size.height;

  bool get isKeyboardVisible => mq.viewInsets.bottom > 0;

  /// Current text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Read the NexusThemeProvider without subscribing to changes.
  NexusThemeProvider get nexusTheme => read<NexusThemeProvider>();

  /// Watch the NexusThemeProvider and rebuild on changes.
  NexusThemeType get nexusThemeType => watch<NexusThemeProvider>().type;

  /// Show a generic SnackBar using the current scaffold messenger.
  void showNexusSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
