import 'package:flutter/material.dart';
import 'dart:async';
import '../../utils/constants.dart';
import '../../app_router.dart';

class WhatIsOnnJoyPage extends StatefulWidget {
  const WhatIsOnnJoyPage({Key? key}) : super(key: key);

  @override
  State<WhatIsOnnJoyPage> createState() => _WhatIsOnnJoyPageState();
}

class _WhatIsOnnJoyPageState extends State<WhatIsOnnJoyPage> with SingleTickerProviderStateMixin {
  String _selectedLang = 'et';
  int _visibleMessagesCount = 0;
  Timer? _timer;

  final List<String> messages = [
    "20 euros a weekly therapy. Don't pay 100 euros for a therapy session.",
    "Start Healing Faster – Share your story before your session for efficient interaction.",
    "AI-Powered Matching – Find your ideal therapist in seconds based on your story.",
    "See Your Therapist, Stay Unseen – Default one-way video for your comfort.",
    "Stay Anonymous, If You Want – Your name, your voice, your choice.",
    "Voice Masking for Extra Privacy – Express yourself freely.",
    "Shape your therapy with 1000 characters message in advance",
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
        if (_visibleMessagesCount < messages.length) {
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
                    Text(
                      'ONNJOY – Therapy, Your Way',
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
                    Text(
                      'Efficient. Private. Affordable.',
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedLang,
                    icon: const Icon(Icons.language, color: Colors.black87),
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'et', child: Text('Estonian')),
                      DropdownMenuItem(value: 'lt', child: Text('Lithuanian')),
                      DropdownMenuItem(value: 'lv', child: Text('Latvian')),
                      DropdownMenuItem(value: 'ru', child: Text('Russian')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedLang = value!);
                    },
                  ),
                ),
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
                          child: Text(
                            messages[index],
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