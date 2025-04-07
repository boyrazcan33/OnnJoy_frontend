import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/constants.dart';
import '../../app_router.dart';
import '../../widgets/common/translate_text.dart';
import '../../widgets/common/language_picker.dart';

class WhatIsOnnJoyPage extends StatefulWidget {
  const WhatIsOnnJoyPage({Key? key}) : super(key: key);

  @override
  State<WhatIsOnnJoyPage> createState() => _WhatIsOnnJoyPageState();
}

class _WhatIsOnnJoyPageState extends State<WhatIsOnnJoyPage> with SingleTickerProviderStateMixin {
  int _visibleMessagesCount = 0;
  Timer? _timer;

  final List<String> messageKeys = [
    "affordableTherapy",
    "startHealingFaster",
    "aiPoweredMatching",
    "seeYourTherapist",
    "stayAnonymous",
    "voiceMasking",
    "shapeYourTherapy"
  ];

  @override
  void initState() {
    super.initState();
    // Start the animation timer after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _startMessageAnimation();
    });
  }

  void _startMessageAnimation() {
    // Show one message at a time with a delay
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        if (_visibleMessagesCount < messageKeys.length) {
          _visibleMessagesCount++;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/welcome-background.png'),
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
                      'efficient',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
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
                  ],
                ),
              ),

              // Language Dropdown - Improved visibility
              Positioned(
                top: 16,
                right: 16,
                child: LanguagePicker(),
              ),

              // Animated Text Boxes
              Positioned(
                top: 140, // Adjusted position to be below the titles
                left: 24,
                right: 24,
                child: Column(
                  children: List.generate(
                    _visibleMessagesCount, // Only show the visible messages so far
                        (index) {
                      return AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            messageKeys[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Pagination
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.horizontal_rule, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Icon(Icons.circle_outlined, color: Colors.white, size: 10),
                    SizedBox(width: 4),
                    Icon(Icons.circle_outlined, color: Colors.white, size: 10),
                  ],
                ),
              ),

              // Forward Button
              Positioned(
                bottom: 20,
                right: 20,
                child: IconButton(
                  icon: Image.asset('assets/icons/step-forward.png', height: 32),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.welcome);
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