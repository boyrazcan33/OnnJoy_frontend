import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../app_router.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String _selectedLang = 'et';

  @override
  Widget build(BuildContext context) {
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
                  onChanged: (val) => setState(() => _selectedLang = val!),
                ),
              ),

              // Main headline texts
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'ONNJOY – Therapy, Your Way',
                        style: TextStyle(
                          fontSize: 24,
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
                      const SizedBox(height: 8),
                      Text(
                        'Efficient. Private. Affordable.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.orangeAccent.shade200,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Instruction texts
              Positioned(
                top: 220,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Let me explain How to Use OnnJoy',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
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
                      '1. Choose your language to communicate with your therapist',
                      '2. After SignUp we will give you an anonymous username',
                      '3. Type in your entry to find the best therapist matches',
                      '4. Book an appointment'
                    ].map((text) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )),
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
