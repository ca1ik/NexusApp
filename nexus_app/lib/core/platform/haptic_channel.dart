import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:nexus_app/core/constants/app_constants.dart';

/// Dart-side bridge to the native Android [HapticFeedbackChannel].
/// On non-Android platforms the methods silently succeed.
class NexusHapticChannel {
  NexusHapticChannel({Logger? logger}) : _log = logger ?? Logger();

  static const MethodChannel _channel = MethodChannel(
    AppConstants.hapticChannelName,
  );

  final Logger _log;

  /// Multi-wave, high-amplitude haptic + audio — fires when THE FRACTURE occurs.
  Future<void> triggerFractureHaptic() async {
    try {
      await _channel.invokeMethod<void>(AppConstants.hapticFractureMethod);
    } on PlatformException catch (e) {
      _log.w('Fracture haptic unavailable: ${e.message}');
    } on MissingPluginException {
      _log.w('Haptic channel not registered (non-Android build).');
    }
  }

  /// Short tension haptic — fires during Arena of Minds confrontations.
  Future<void> triggerArenaHaptic() async {
    try {
      await _channel.invokeMethod<void>(AppConstants.hapticArenaMethod);
    } on PlatformException catch (e) {
      _log.w('Arena haptic unavailable: ${e.message}');
    } on MissingPluginException {
      _log.w('Haptic channel not registered (non-Android build).');
    }
  }
}
