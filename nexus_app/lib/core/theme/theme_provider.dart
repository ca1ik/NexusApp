import 'package:flutter/material.dart';
import 'package:nexus_app/core/theme/app_theme.dart';

class NexusThemeProvider extends ChangeNotifier {
  NexusThemeType _type = NexusThemeType.mirror;

  NexusThemeType get type => _type;

  ThemeData get currentTheme => switch (_type) {
    NexusThemeType.mirror => AppTheme.buildMirrorTheme(),
    NexusThemeType.fracture => AppTheme.buildFractureTheme(),
    NexusThemeType.arena => AppTheme.buildArenaTheme(),
  };

  void setTheme(NexusThemeType next) {
    if (_type == next) return;
    _type = next;
    notifyListeners();
  }

  void triggerFracture() => setTheme(NexusThemeType.fracture);
  void activateArena() => setTheme(NexusThemeType.arena);
  void resetToMirror() => setTheme(NexusThemeType.mirror);
}
