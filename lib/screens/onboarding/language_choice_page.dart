import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../app_router.dart';

class LanguageChoicePage extends StatefulWidget {
  const LanguageChoicePage({Key? key}) : super(key: key);

  @override
  State<LanguageChoicePage> createState() => _LanguageChoicePageState();
}

class _LanguageChoicePageState extends State<LanguageChoicePage> {
  String _selectedLang = 'et';

  final Map<String, String> _languageFlags = {
    'en': 'assets/flags/uk.png',
    'et': 'assets/flags/estonia.png',
    'lt': 'assets/flags/lithuania.png',
    'lv': 'assets/flags/latvia.png',
    'ru': 'assets/flags/russia.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/calm-background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Logo
              Positioned(
                top: 16,
                left: 16,
                child: Image.asset('assets/icons/logo.png', height: 40),
              ),

              // Main Title with Bold, Large, Orange style
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Confirm Your Therapy Language',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Language Options
              Positioned(
                top: 150,
                left: 24,
                right: 24,
                child: Column(
                  children: _languageFlags.entries.map((entry) {
                    final code = entry.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLang = code),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedLang == code
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedLang == code ? Colors.teal : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(entry.value, width: 32),
                            const SizedBox(width: 16),
                            Text(
                              _getLanguageName(code),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Pagination indicator
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.circle_outlined, color: Colors.white, size: 10),
                    SizedBox(width: 4),
                    Icon(Icons.circle_outlined, color: Colors.white, size: 10),
                    SizedBox(width: 4),
                    Icon(Icons.horizontal_rule, color: Colors.white, size: 18),
                  ],
                ),
              ),

              // Backward Button
              Positioned(
                bottom: 20,
                left: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.welcome),
                  child: Image.asset('assets/icons/step-backward.png', height: 32),
                ),
              ),

              // Forward Button
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.signup, arguments: _selectedLang),
                  child: Image.asset('assets/icons/step-forward.png', height: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
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
        return '';
    }
  }
}
