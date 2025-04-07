import 'dart:ui';

/// A utility class for language and localization operations
class LanguageUtils {
  /// Get the language name from a language code
  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'et':
        return 'Estonian';
      case 'lt':
        return 'Lithuanian';
      case 'lv':
        return 'Latvian';
      case 'ru':
        return 'Russian';
      default:
        return code;
    }
  }

  /// Get the native language name from a language code
  static String getNativeLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'et':
        return 'Eesti';
      case 'lt':
        return 'Lietuvių';
      case 'lv':
        return 'Latviešu';
      case 'ru':
        return 'Русский';
      default:
        return code;
    }
  }

  /// Get the flag asset path for a language code
  static String getFlagAsset(String code) {
    switch (code) {
      case 'en':
        return 'assets/flags/uk.png';
      case 'et':
        return 'assets/flags/estonia.png';
      case 'lt':
        return 'assets/flags/lithuania.png';
      case 'lv':
        return 'assets/flags/latvia.png';
      case 'ru':
        return 'assets/flags/russia.png';
      default:
        return 'assets/flags/uk.png';
    }
  }

  /// Check if a language is supported
  static bool isLanguageSupported(String code) {
    return ['en', 'et', 'lt', 'lv', 'ru'].contains(code);
  }

  /// Get the default language based on device locale
  static String getDefaultLanguage() {
    final deviceLocale = PlatformDispatcher.instance.locale.languageCode;

    // Check if the device language is supported
    if (isLanguageSupported(deviceLocale)) {
      return deviceLocale;
    }

    // Default to English
    return 'en';
  }

  /// Get all supported language codes
  static List<String> getSupportedLanguages() {
    return ['en', 'et', 'lt', 'lv', 'ru'];
  }
}