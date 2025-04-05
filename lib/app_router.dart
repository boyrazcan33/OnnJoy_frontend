import 'package:flutter/material.dart';

import 'screens/onboarding/what_is_onnjoy.dart';
import 'screens/onboarding/welcome_page.dart';
import 'screens/onboarding/language_choice_page.dart';
import 'screens/auth/signup_page.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/reset_password_page.dart';
import 'screens/auth/therapist_login_page.dart';
import 'screens/home/entry_page.dart';
import 'screens/home/therapist_matches_page.dart';
import 'screens/home/therapist_profile_page.dart';
import 'screens/home/therapist_calendar_page.dart';
import 'screens/home/package_selection_page.dart';
import 'screens/home/payment_checkout_page.dart';
import 'screens/appointments/user_appointments_page.dart';
import 'screens/appointments/video_call_page.dart';
import 'screens/notifications/notifications_page.dart';
import 'screens/settings/settings_page.dart';

class AppRoutes {
  static const String whatIsOnnJoy = '/onboarding/what-is-onnjoy';
  static const String welcome = '/onboarding/welcome';
  static const String languageChoice = '/onboarding/language-choice';
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String therapistLogin = '/auth/therapist-login';
  static const String resetPassword = '/auth/reset-password';
  static const String entry = '/home/entry';
  static const String matches = '/home/matches';
  static const String therapistProfile = '/home/therapist-profile';
  static const String therapistCalendar = '/home/calendar';
  static const String packages = '/home/packages';
  static const String payment = '/home/payment';
  static const String appointments = '/appointments';
  static const String videoCall = '/video-call';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.whatIsOnnJoy:
      return MaterialPageRoute(builder: (_) => const WhatIsOnnJoyPage());
    case AppRoutes.welcome:
      return MaterialPageRoute(builder: (_) => const WelcomePage());
    case AppRoutes.languageChoice:
      return MaterialPageRoute(builder: (_) => const LanguageChoicePage());
    case AppRoutes.signup:
      return MaterialPageRoute(builder: (_) => const SignUpPage());
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginPage());
    case AppRoutes.therapistLogin:
      return MaterialPageRoute(builder: (_) => const TherapistLoginPage());
    case AppRoutes.resetPassword:
      return MaterialPageRoute(builder: (_) => const ResetPasswordPage());
    case AppRoutes.entry:
      return MaterialPageRoute(builder: (_) => const EntryPage());
    case AppRoutes.matches:
      return MaterialPageRoute(builder: (_) => const TherapistMatchesPage());
    case AppRoutes.therapistProfile:
    // Handle missing or null arguments for therapist profile
      if (settings.arguments == null) {
        return MaterialPageRoute(
          builder: (BuildContext context) => Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "No therapist data provided",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return MaterialPageRoute(builder: (_) => const TherapistProfilePage());
    case AppRoutes.therapistCalendar:
      return MaterialPageRoute(builder: (_) => const TherapistCalendarPage());
    case AppRoutes.packages:
      return MaterialPageRoute(builder: (_) => const PackageSelectionPage());
    case AppRoutes.payment:
      return MaterialPageRoute(builder: (_) => const PaymentCheckoutPage());
    case AppRoutes.appointments:
      return MaterialPageRoute(builder: (_) => const UserAppointmentsPage());
    case AppRoutes.videoCall:
      return MaterialPageRoute(builder: (_) => const VideoCallPage(
        channelName: 'sampleChannel',
        token: 'token',
        uid: 0,
      ));
    case AppRoutes.notifications:
      return MaterialPageRoute(builder: (_) => const NotificationsPage());
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => const SettingsPage());
    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Route not found')),
        ),
      );
  }
}