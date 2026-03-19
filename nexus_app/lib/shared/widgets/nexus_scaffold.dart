import 'package:flutter/material.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';
import 'package:nexus_app/core/theme/app_theme.dart';
import 'package:nexus_app/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

/// A standard full-screen Scaffold that applies the current Nexus theme
/// background and wraps content in a safe area. Keeps page widgets clean.
class NexusScaffold extends StatelessWidget {
  const NexusScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<NexusThemeProvider>();
    final bg = _backgroundFor(themeProvider.type);

    return Scaffold(
      backgroundColor: bg,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(child: body),
    );
  }

  Color _backgroundFor(NexusThemeType type) {
    return switch (type) {
      NexusThemeType.mirror => ThemeConstants.mirrorBg,
      NexusThemeType.fracture => ThemeConstants.fractureBg,
      NexusThemeType.arena => ThemeConstants.arenaBg,
    };
  }
}
