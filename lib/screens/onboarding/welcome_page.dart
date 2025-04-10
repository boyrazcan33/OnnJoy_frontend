import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../app_router.dart';
import '../../providers/language_provider.dart';
import '../../widgets/common/language_picker.dart';
import '../../widgets/common/translate_text.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/howtouse.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Logo and Main Titles - Left aligned
              Positioned(
                top: 16,
                left: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Left align the content
                  children: [
                    Image.asset('assets/icons/logo.png', height: 50),
                    const SizedBox(height: 12),
                    TranslateText(
                      'therapyYourWay',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.anthracite,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TranslateText(
                      'efficientPrivateAffordable',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Language Dropdown - Now using our custom language picker
              Positioned(
                top: 16,
                right: 16,
                child: LanguagePicker(),
              ),

              // Instruction texts with styled containers - Adjusted position
              Positioned(
                top: 150, // Adjusted to position below the titles
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslateText(
                      'whatIsOnnJoy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.anthracite,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...[
                      'welcomeStep1',
                      'welcomeStep2',
                      'welcomeStep3',
                      'welcomeStep4'
                    ].map((key) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TranslateText(
                        key,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ],
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
                    Icon(Icons.horizontal_rule, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Icon(Icons.circle_outlined, color: Colors.white, size: 10),
                  ],
                ),
              ),

              // Backward button
              Positioned(
                bottom: 20,
                left: 20,
                child: IconButton(
                  icon: Image.asset('assets/icons/step-backward.png', height: 32),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.whatIsOnnJoy);
                  },
                ),
              ),

              // Forward button
              Positioned(
                bottom: 20,
                right: 20,
                child: IconButton(
                  icon: Image.asset('assets/icons/step-forward.png', height: 32),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.languageChoice);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}