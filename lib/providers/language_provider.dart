import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
import 'auth_provider.dart';

class LanguageProvider extends ChangeNotifier {
  final LanguageService _languageService = LanguageService();
  String _currentLanguage = 'en';
  final Map<String, Map<String, String>> _translations = {};
  bool _isLoaded = false;

  String get currentLanguage => _currentLanguage;
  bool get isLoaded => _isLoaded;

  // Initialize provider by loading saved language
  Future<void> initialize() async {
    if (_isLoaded) return;

    try {
      // Get default language from device locale or saved preference
      final prefs = await SharedPreferences.getInstance();
      final deviceLocale = PlatformDispatcher.instance.locale.languageCode;

      // Check if the device language is supported
      String defaultLang = 'en';
      if (['en', 'et', 'lt', 'lv', 'ru'].contains(deviceLocale)) {
        defaultLang = deviceLocale;
      }

      // Use saved language or default
      _currentLanguage = prefs.getString('language') ?? defaultLang;

      // Load translations
      await loadTranslations();
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing language provider: $e');
    }
  }

  // Change the app language
  Future<void> setLanguage(String langCode, {String? token}) async {
    if (_currentLanguage == langCode) return;

    try {
      _currentLanguage = langCode;

      // Save language locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', langCode);

      // If token is provided, update language in backend too
      if (token != null) {
        await _languageService.updateUserLanguage(
          language: langCode,
          token: token,
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  // Set language with auth context
  Future<void> setLanguageWithAuth(BuildContext context, String langCode) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      await setLanguage(langCode, token: authProvider.token);
    } else {
      await setLanguage(langCode);
    }
  }

  // Load translations for all supported languages
  Future<void> loadTranslations() async {
    try {
      // Load translations for each supported language
      await _loadLanguageFile('en');
      await _loadLanguageFile('et');
      await _loadLanguageFile('lt');
      await _loadLanguageFile('lv');
      await _loadLanguageFile('ru');
    } catch (e) {
      debugPrint('Error loading translations: $e');
    }
  }

  // Load translations for a specific language from a JSON file
  Future<void> _loadLanguageFile(String langCode) async {
    try {
      final jsonString = await rootBundle.loadString('assets/i18n/$langCode.json');
      final jsonMap = jsonDecode(jsonString);

      // Convert the dynamic map to a String map
      _translations[langCode] = Map<String, String>.from(jsonMap);

      debugPrint('Loaded ${_translations[langCode]?.length} translations for $langCode');
    } catch (e) {
      debugPrint('Error loading translations for $langCode: $e');

      // Fallback to default translations if loading fails
      _translations[langCode] = _getFallbackTranslations(langCode);
    }
  }

  // Get translation for a key in the current language
  String translate(String key, {Map<String, String>? params}) {
    // Return the key if translations aren't loaded yet
    if (!_isLoaded || !_translations.containsKey(_currentLanguage)) {
      return key;
    }

    // Get the translation or use the key if not found
    String translation = _translations[_currentLanguage]?[key] ?? key;

    // Replace parameters if provided
    if (params != null) {
      params.forEach((param, value) {
        translation = translation.replaceAll('{$param}', value);
      });
    }

    return translation;
  }

  // Fallback translations in case JSON files can't be loaded
  Map<String, String> _getFallbackTranslations(String langCode) {
    switch (langCode) {
      case 'en':
        return {
          'welcome': 'Welcome',
          'chooseLanguage': 'Choose your language',
          'email': 'Email',
          'password': 'Password',
          'login': 'Login',
          'signup': 'Sign Up',
          // Add more essential fallback translations
        };
      case 'et':
        return {
          'welcome': 'Tere tulemast',
          'chooseLanguage': 'Vali oma keel',
          'email': 'E-post',
          'password': 'Parool',
          'login': 'Logi sisse',
          'signup': 'Registreeru',
          // Add more essential fallback translations
        };
      default:
        return {};
    }
  }
}