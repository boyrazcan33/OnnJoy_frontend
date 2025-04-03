import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../app_router.dart';

class WhatIsOnnJoyPage extends StatefulWidget {
  const WhatIsOnnJoyPage({Key? key}) : super(key: key);

  @override
  State<WhatIsOnnJoyPage> createState() => _WhatIsOnnJoyPageState();
}

class _WhatIsOnnJoyPageState extends State<WhatIsOnnJoyPage> {
  String _selectedLang = 'et';

  final List<String> messages = [
    "20 euros a weekly therapy. Don’t pay 100 euros for a therapy session.",
    "Start Healing Faster – Share your story before your session for efficient interaction.",
    "AI-Powered Matching – Find your ideal therapist in seconds based on your story.",
    "See Your Therapist, Stay Unseen – Default one-way video for your comfort.",
    "Stay Anonymous, If You Want – Your name, your voice, your choice.",
    "Voice Masking for Extra Privacy – Express yourself freely.",
    "Shape your therapy with 1000 characters message in advance",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/welcome-background.jpg'),
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

              // Language Dropdown
              Positioned(
                top: 16,
                right: 16,
                child: DropdownButton<String>(
                  value: _selectedLang,
                  icon: const Icon(Icons.language, color: Colors.white),
                  dropdownColor: Colors.white,
                  underline: const SizedBox(),
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

              // Centered Text
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: messages.map((msg) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          msg,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.6),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
