import 'package:flutter/material.dart';

/// Color palette used across the OnnJoy app
class AppColors {
  static const Color primary = Color(0xFF005C65);        // Teal
  static const Color secondary = Color(0xFF94A3B8);      // Muted Blue-Grey
  static const Color accent = Color(0xFF00A8B0);         // Cyan
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color textPrimaryLight = Color(0xFF030303);
  static const Color textPrimaryDark = Color(0xFFF1F6F7);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);
  static const Color disabled = Color(0xFF94A3B8);

  // Aliases used in various parts of UI for compatibility
  static const Color primaryColor = primary;
  static const Color secondaryColor = secondary;
  static const Color unreadNotification = warning;
}

/// Font sizes for consistent typography
class AppTextSizes {
  static const double heading1 = 24;
  static const double heading2 = 20;
  static const double body = 16;
  static const double secondary = 14;
  static const double button = 14;
  static const double small = 12;
}

/// Font weights used in the app
class AppFontWeights {
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight regular = FontWeight.w400;
}

/// Padding and spacing values
class AppSpacing {
  static const double screenPadding = 16;
  static const double itemSpacing = 12;
  static const double sectionSpacing = 24;
  static const double fieldSpacing = 10;
}

/// Corner radius values for consistent shape styling
class AppCorners {
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
}
