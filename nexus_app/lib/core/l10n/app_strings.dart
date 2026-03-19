import 'package:flutter/material.dart';
import 'package:nexus_app/core/l10n/locale_provider.dart';
import 'package:provider/provider.dart';

/// All user-facing strings with EN / TR support.
abstract final class AppStrings {
  // ── Splash ────────────────────────────────────────────────────────────────
  static const _nexusOfPower = {
    'en': 'THE NEXUS OF POWER',
    'tr': 'GÜÇ BAĞLANTISI'
  };
  static const _initializing = {
    'en': 'INITIALIZING...',
    'tr': 'BAŞLATILIYOR...'
  };

  // ── Login ─────────────────────────────────────────────────────────────────
  static const _appTitle = {
    'en': 'THE NEXUS\nOF POWER',
    'tr': 'GÜÇ\nBAĞLANTISI'
  };
  static const _appTagline = {
    'en': '"Create your best version.\nBattle it. Or ally with it."',
    'tr': '"En iyi versiyonunu oluştur.\nSavaş. Ya da müttefik ol."',
  };
  static const _enterAsSeeker = {
    'en': 'ENTER AS A SEEKER',
    'tr': 'ARAYAN OLARAK GİR'
  };
  static const _enterAsGuest = {
    'en': 'CONTINUE AS GUEST',
    'tr': 'MİSAFİR OLARAK DEVAM ET'
  };
  static const _signInWithEmail = {
    'en': 'SIGN IN WITH EMAIL',
    'tr': 'E-POSTA İLE GİRİŞ'
  };
  static const _hideSignIn = {'en': 'HIDE SIGN IN', 'tr': 'GİRİŞİ GİZLE'};
  static const _signUp = {'en': 'SIGN UP', 'tr': 'KAYIT OL'};
  static const _signIn = {'en': 'SIGN IN', 'tr': 'GİRİŞ YAP'};
  static const _enter = {'en': 'ENTER', 'tr': 'GİR'};
  static const _email = {'en': 'Email', 'tr': 'E-posta'};
  static const _password = {'en': 'Password', 'tr': 'Şifre'};
  static const _confirmPassword = {
    'en': 'Confirm Password',
    'tr': 'Şifre Tekrar'
  };
  static const _journeyBegins = {
    'en': 'Your journey into the self begins here.',
    'tr': 'Benliğe yolculuğun burada başlıyor.',
  };
  static const _accessDenied = {
    'en': 'Access Denied',
    'tr': 'Erişim Reddedildi'
  };
  static const _noAccount = {
    'en': "Don't have an account?",
    'tr': 'Hesabın yok mu?'
  };
  static const _alreadyHaveAccount = {
    'en': 'Already have an account?',
    'tr': 'Zaten hesabın var mı?'
  };
  static const _passwordsDoNotMatch = {
    'en': 'Passwords do not match',
    'tr': 'Şifreler uyuşmuyor'
  };
  static const _or = {'en': 'OR', 'tr': 'VEYA'};

  // ── Mirror ────────────────────────────────────────────────────────────────
  static const _theMirror = {'en': 'THE MIRROR', 'tr': 'AYNA'};
  static const _speakYourTruth = {
    'en': 'Speak your truth...',
    'tr': 'Gerçeğini söyle...'
  };

  // ── Fracture ──────────────────────────────────────────────────────────────
  static const _theFracture = {'en': 'THE FRACTURE', 'tr': 'KIRILMA'};
  static const _fractureSubtitle = {
    'en': 'You have outgrown your first self.\nNow — who do you become?',
    'tr': 'İlk benliğini aştın.\nŞimdi — kim oluyorsun?',
  };
  static const _shadowNexus = {'en': 'SHADOW\nNEXUS', 'tr': 'GÖLGE\nBAĞLANTI'};
  static const _primeNexus = {'en': 'PRIME\nNEXUS', 'tr': 'ANA\nBAĞLANTI'};
  static const _battle = {'en': '⚔  BATTLE', 'tr': '⚔  SAVAŞ'};
  static const _ally = {'en': '✦  ALLY', 'tr': '✦  MÜTTEFİK'};
  static const _enterTheArena = {'en': 'ENTER THE ARENA', 'tr': 'ARENAYA GİR'};

  // ── Arena ─────────────────────────────────────────────────────────────────
  static const _theArena = {'en': 'THE ARENA', 'tr': 'ARENA'};
  static const _tension = {'en': 'TENSION', 'tr': 'GERGİNLİK'};
  static const _selectScenario = {
    'en': 'Select a scenario to begin.',
    'tr': 'Başlamak için bir senaryo seç.'
  };
  static const _mountYourArgument = {
    'en': 'Mount your argument...',
    'tr': 'Argümanını sun...'
  };
  static const _analyzeWeakness = {
    'en': 'ANALYZE WEAKNESS',
    'tr': 'ZAYIFLIK ANALİZİ'
  };
  static const _weaknessDossier = {
    'en': 'WEAKNESS DOSSIER',
    'tr': 'ZAYIFLIK DOSYASI'
  };

  // ── Paywall ───────────────────────────────────────────────────────────────
  static const _unlockTheNexus = {
    'en': 'UNLOCK THE NEXUS',
    'tr': 'BAĞLANTIYI AÇ'
  };
  static const _everyLevelHasPrice = {
    'en': 'Every level of power has its price.',
    'tr': 'Her güç seviyesinin bir bedeli var.',
  };
  static const _accessGranted = {
    'en': 'ACCESS GRANTED',
    'tr': 'ERİŞİM VERİLDİ'
  };
  static const _nexusUpgraded = {
    'en': 'Your nexus has been upgraded.',
    'tr': 'Bağlantın yükseltildi.'
  };
  static const _transactionDenied = {
    'en': 'TRANSACTION DENIED',
    'tr': 'İŞLEM REDDEDİLDİ'
  };
  static const _restorePurchases = {
    'en': 'Restore Purchases',
    'tr': 'Satın Alımları Geri Yükle'
  };
  static const _subscriptionDisclaimer = {
    'en': 'Subscriptions auto-renew unless cancelled 24h before period end.',
    'tr':
        'Abonelikler dönem bitiminden 24 saat önce iptal edilmezse otomatik yenilenir.',
  };
  static const _mostPopular = {'en': 'MOST POPULAR', 'tr': 'EN POPÜLER'};
  static const _perPeriod = {'en': 'per period', 'tr': 'dönem başı'};

  // ── Settings ──────────────────────────────────────────────────────────────
  static const _settings = {'en': 'SETTINGS', 'tr': 'AYARLAR'};
  static const _language = {'en': 'Language', 'tr': 'Dil'};
  static const _english = {'en': 'English', 'tr': 'İngilizce'};
  static const _turkish = {'en': 'Turkish', 'tr': 'Türkçe'};
  static const _signOut = {'en': 'SIGN OUT', 'tr': 'ÇIKIŞ YAP'};
  static const _account = {'en': 'Account', 'tr': 'Hesap'};
  static const _appearance = {'en': 'Appearance', 'tr': 'Görünüm'};

  // ── Getters (context-aware) ───────────────────────────────────────────────
  static String _get(BuildContext context, Map<String, String> map) {
    final locale = context.read<NexusLocaleProvider>().locale.languageCode;
    return map[locale] ?? map['en']!;
  }

  // Splash
  static String nexusOfPower(BuildContext c) => _get(c, _nexusOfPower);
  static String initializing(BuildContext c) => _get(c, _initializing);

  // Login
  static String appTitle(BuildContext c) => _get(c, _appTitle);
  static String appTagline(BuildContext c) => _get(c, _appTagline);
  static String enterAsSeeker(BuildContext c) => _get(c, _enterAsSeeker);
  static String enterAsGuest(BuildContext c) => _get(c, _enterAsGuest);
  static String signInWithEmail(BuildContext c) => _get(c, _signInWithEmail);
  static String hideSignIn(BuildContext c) => _get(c, _hideSignIn);
  static String signUp(BuildContext c) => _get(c, _signUp);
  static String signIn(BuildContext c) => _get(c, _signIn);
  static String enter(BuildContext c) => _get(c, _enter);
  static String email(BuildContext c) => _get(c, _email);
  static String password(BuildContext c) => _get(c, _password);
  static String confirmPassword(BuildContext c) => _get(c, _confirmPassword);
  static String journeyBegins(BuildContext c) => _get(c, _journeyBegins);
  static String accessDenied(BuildContext c) => _get(c, _accessDenied);
  static String noAccount(BuildContext c) => _get(c, _noAccount);
  static String alreadyHaveAccount(BuildContext c) =>
      _get(c, _alreadyHaveAccount);
  static String passwordsDoNotMatch(BuildContext c) =>
      _get(c, _passwordsDoNotMatch);
  static String or(BuildContext c) => _get(c, _or);

  // Mirror
  static String theMirror(BuildContext c) => _get(c, _theMirror);
  static String speakYourTruth(BuildContext c) => _get(c, _speakYourTruth);

  // Fracture
  static String theFracture(BuildContext c) => _get(c, _theFracture);
  static String fractureSubtitle(BuildContext c) => _get(c, _fractureSubtitle);
  static String shadowNexus(BuildContext c) => _get(c, _shadowNexus);
  static String primeNexus(BuildContext c) => _get(c, _primeNexus);
  static String battle(BuildContext c) => _get(c, _battle);
  static String allyLabel(BuildContext c) => _get(c, _ally);
  static String enterTheArena(BuildContext c) => _get(c, _enterTheArena);

  // Arena
  static String theArena(BuildContext c) => _get(c, _theArena);
  static String tension(BuildContext c) => _get(c, _tension);
  static String selectScenario(BuildContext c) => _get(c, _selectScenario);
  static String mountYourArgument(BuildContext c) =>
      _get(c, _mountYourArgument);
  static String analyzeWeakness(BuildContext c) => _get(c, _analyzeWeakness);
  static String weaknessDossier(BuildContext c) => _get(c, _weaknessDossier);

  // Paywall
  static String unlockTheNexus(BuildContext c) => _get(c, _unlockTheNexus);
  static String everyLevelHasPrice(BuildContext c) =>
      _get(c, _everyLevelHasPrice);
  static String accessGranted(BuildContext c) => _get(c, _accessGranted);
  static String nexusUpgraded(BuildContext c) => _get(c, _nexusUpgraded);
  static String transactionDenied(BuildContext c) =>
      _get(c, _transactionDenied);
  static String restorePurchases(BuildContext c) => _get(c, _restorePurchases);
  static String subscriptionDisclaimer(BuildContext c) =>
      _get(c, _subscriptionDisclaimer);
  static String mostPopular(BuildContext c) => _get(c, _mostPopular);
  static String perPeriod(BuildContext c) => _get(c, _perPeriod);

  // Settings
  static String settings(BuildContext c) => _get(c, _settings);
  static String language(BuildContext c) => _get(c, _language);
  static String english(BuildContext c) => _get(c, _english);
  static String turkish(BuildContext c) => _get(c, _turkish);
  static String signOutLabel(BuildContext c) => _get(c, _signOut);
  static String account(BuildContext c) => _get(c, _account);
  static String appearance(BuildContext c) => _get(c, _appearance);
}
