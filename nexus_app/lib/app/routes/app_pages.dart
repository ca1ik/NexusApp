import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nexus_app/app/routes/app_routes.dart';
import 'package:nexus_app/features/auth/presentation/pages/login_page.dart';
import 'package:nexus_app/features/auth/presentation/pages/splash_page.dart';
import 'package:nexus_app/features/monetization/presentation/pages/paywall_page.dart';
import 'package:nexus_app/features/persona/presentation/pages/arena_page.dart';
import 'package:nexus_app/features/persona/presentation/pages/fracture_page.dart';
import 'package:nexus_app/features/persona/presentation/pages/mirror_page.dart';
import 'package:nexus_app/features/settings/presentation/pages/settings_page.dart';

abstract final class AppPages {
  static final List<GetPage<Widget>> routes = [
    GetPage<Widget>(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
    ),
    GetPage<Widget>(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.leftToRight,
    ),
    GetPage<Widget>(
      name: AppRoutes.mirror,
      page: () => const MirrorPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage<Widget>(
      name: AppRoutes.fracture,
      page: () => const FracturePage(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 1200),
    ),
    GetPage<Widget>(
      name: AppRoutes.arena,
      page: () => const ArenaPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage<Widget>(
      name: AppRoutes.paywall,
      page: () => const PaywallPage(),
      transition: Transition.downToUp,
    ),
    GetPage<Widget>(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}
