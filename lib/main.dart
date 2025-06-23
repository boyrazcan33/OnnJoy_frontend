import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/auth_provider.dart';
import 'providers/therapist_provider.dart';
import 'providers/language_provider.dart';
import 'utils/constants.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final languageProvider = LanguageProvider();
  await languageProvider.initialize();

  runApp(OnnJoyApp(languageProvider: languageProvider));
}

class OnnJoyApp extends StatelessWidget {
  final LanguageProvider languageProvider;

  const OnnJoyApp({
    super.key,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TherapistProvider()),
        ChangeNotifierProvider.value(value: languageProvider),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'OnnJoy',
            theme: ThemeData(
              scaffoldBackgroundColor: AppColors.backgroundLight,
              primaryColor: AppColors.primary,
              fontFamily: 'Roboto',
              useMaterial3: true,
            ),
            // Add localization support
            locale: Locale(languageProvider.currentLanguage),
            supportedLocales: const [
              Locale('en'), // English
              Locale('et'), // Estonian
              Locale('lt'), // Lithuanian
              Locale('lv'), // Latvian
              Locale('ru'), // Russian
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppRoutes.whatIsOnnJoy,
            onGenerateRoute: generateRoute,
          );
        },
      ),
    );
  }
}