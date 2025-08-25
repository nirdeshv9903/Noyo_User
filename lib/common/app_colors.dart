import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors - Modern Blue-Green Gradient
  static const Color primary = Color(0xFF39abe1); // Modern Blue
  static const Color primaryLight = Color(0xFF39abe1); // Lighter Blue
  static const Color primaryDark = Color(0xFF39abe1); // Darker Blue
  static const Color secondary = Color(0xFF10B981); // Emerald Green
  static const Color secondaryLight = Color(0xFF34D399); // Light Emerald
  static const Color secondaryDark = Color(0xFF059669); // Dark Emerald

  // Accent Colors
  static const Color accent = Color(0xFFF59E0B); // Amber
  static const Color accentLight = Color(0xFFFBBF24); // Light Amber
  static const Color accentDark = Color(0xFFD97706); // Dark Amber

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF6B7280); // Modern Gray
  static const Color greyLight = Color(0xFFF3F4F6); // Light Gray
  static const Color greyDark = Color(0xFF374151); // Dark Gray
  static const Color greyHintColor = Color(0xFF9CA3AF); // Hint Gray
  static const Color greyHeader =
      Color(0xFF99AABE); // Header Gray (for backward compatibility)
  static const Color transparent = Colors.transparent;

  // Status Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color successLight = Color(0xFFD1FAE5); // Light Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFEF3C7); // Light Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFFEE2E2); // Light Red
  static const Color info = Color(0xFF39abe1); // Blue
  static const Color infoLight = Color(0xFFDBEAFE); // Light Blue

  // Legacy Colors (for backward compatibility)
  static const Color red = Color(0xFFEF4444); // Same as error
  static const Color green = Color(0xFF10B981); // Same as success

  // Background Colors
  static const Color background = Color(0xFFF8FAFC); // Very Light Blue-Gray
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Light Blue-Gray
  static const Color surfaceContainerHighest =
      Color(0xFFF1F5F9); // Same as surfaceVariant for compatibility

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937); // Dark Gray
  static const Color textSecondary = Color(0xFF6B7280); // Medium Gray
  static const Color textTertiary = Color(0xFF9CA3AF); // Light Gray
  static const Color textInverse = Color(0xFFFFFFFF); // White

  // Border Colors
  static const Color border = Color(0xFFE5E7EB); // Light Gray
  static const Color borderLight = Color(0xFFF3F4F6); // Very Light Gray

  // Shadow Colors
  static const Color shadow = Color(0x1A000000); // 10% Black
  static const Color shadowLight = Color(0x0A000000); // 4% Black

  // Legacy Colors (for backward compatibility)
  static const MaterialColor darkGrey = Colors.grey;
  static const MaterialColor blue = Colors.blue;
  static const MaterialColor orange = Colors.orange;
  static const Color goldenColor = Color(0xFFF59E0B); // Updated to match accent

  // Button Colors
  static const Color buttonColor = primary;
  static const Color buttonTextColor = white;
  static const Color buttonSecondaryColor = secondary;
  static const Color buttonOutlineColor = primary;

  // Selection Colors
  static Color textSelectionColor = primary.withValues(alpha: 0.3);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, surfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
