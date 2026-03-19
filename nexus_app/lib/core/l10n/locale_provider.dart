import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the current locale and persists the user's language choice.
class NexusLocaleProvider extends ChangeNotifier {
  NexusLocaleProvider() {
    _loadSavedLocale();
  }

  static const String _key = 'nexus_locale';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isEnglish => _locale.languageCode == 'en';
  bool get isTurkish => _locale.languageCode == 'tr';

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && code != _locale.languageCode) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, newLocale.languageCode);
  }

  Future<void> toggleLanguage() async {
    final next = isEnglish ? const Locale('tr') : const Locale('en');
    await setLocale(next);
  }
}
