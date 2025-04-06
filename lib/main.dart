import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/therapist_provider.dart'; // Add this import
import 'utils/constants.dart';
import 'app_router.dart';

void main() {
  runApp(const OnnJoyApp());
}

class OnnJoyApp extends StatelessWidget {
  const OnnJoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TherapistProvider()), // Add this provider
        // Other providers can be added here
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OnnJoy',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundLight,
          primaryColor: AppColors.primary,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.whatIsOnnJoy,
        onGenerateRoute: generateRoute,
      ),
    );
  }
}