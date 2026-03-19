// ================================================================
// The Nexus of Power — main.dart
// Entry point: boots Firebase, Hive, DI, RevenueCat, then launches.
// ================================================================
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:nexus_app/app/app.dart';
import 'package:nexus_app/core/constants/app_constants.dart';
import 'package:nexus_app/core/di/injection.dart';
import 'package:nexus_app/firebase_options.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final Logger appLog = Logger(
  printer: PrettyPrinter(methodCount: 2, colors: true, printEmojis: true),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for immersive experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Full edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Local persistence
  await Hive.initFlutter();

  // Firebase — wraps error so dev build runs without google-services.json
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    appLog.w('Firebase init skipped (run flutterfire configure): $e');
  }

  // Dependency injection
  configureDependencies();

  // RevenueCat
  try {
    final config = PurchasesConfiguration(AppConstants.revenueCatApiKey);
    await Purchases.configure(config);
    await Purchases.setLogLevel(LogLevel.debug);
  } catch (e) {
    appLog.w('RevenueCat init skipped: $e');
  }

  runApp(const NexusApp());
}

// ── end of main.dart ──────────────────────────────────────────────────────────
