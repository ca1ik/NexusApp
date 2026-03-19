import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';
import 'package:nexus_app/core/l10n/app_strings.dart';
import 'package:nexus_app/core/l10n/locale_provider.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:nexus_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:nexus_app/app/routes/app_routes.dart';
import 'package:provider/provider.dart';

/// Settings page — language toggle and sign out.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.mirrorBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(child: _buildContent(context)),
          ],
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
            AppStrings.settings(context),
            style: const TextStyle(
              color: ThemeConstants.mirrorAccent,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<NexusLocaleProvider>(
      builder: (ctx, localeProvider, _) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Language section
            Text(
              AppStrings.language(context),
              style: const TextStyle(
                color: ThemeConstants.mirrorAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            _buildLanguageTile(
              context,
              label: AppStrings.english(context),
              flag: '🇬🇧',
              isSelected: localeProvider.isEnglish,
              onTap: () => localeProvider.setLocale(const Locale('en')),
            ),
            const SizedBox(height: 8),
            _buildLanguageTile(
              context,
              label: AppStrings.turkish(context),
              flag: '🇹🇷',
              isSelected: localeProvider.isTurkish,
              onTap: () => localeProvider.setLocale(const Locale('tr')),
            ),
            const SizedBox(height: 32),

            // Account section
            Text(
              AppStrings.account(context),
              style: const TextStyle(
                color: ThemeConstants.mirrorAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context,
              icon: Icons.logout_rounded,
              label: AppStrings.signOutLabel(context),
              color: ThemeConstants.fracturePrimary,
              onTap: () {
                context.read<AuthBloc>().add(const SignOutRequested());
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String label,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ThemeConstants.mirrorSurface,
          border: Border.all(
            color: isSelected
                ? ThemeConstants.mirrorPrimary
                : ThemeConstants.mirrorSurface,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ThemeConstants.mirrorGlow,
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? ThemeConstants.mirrorAccent
                      : ThemeConstants.textSecondary,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: ThemeConstants.mirrorPrimary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ThemeConstants.mirrorSurface,
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
