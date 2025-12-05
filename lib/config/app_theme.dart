import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Nature Inspired Hiking Theme
  static const Color primaryGreen = Color(0xFF2D5016); // Dark forest green
  static const Color secondaryGreen = Color(0xFF4A7C2C); // Medium forest green
  static const Color accentGreen = Color(0xFF7CB342); // Light nature green
  static const Color lightGreen = Color(0xFFE8F5E9); // Very light green
  
  // Accent Colors
  static const Color sunsetOrange = Color(0xFFFF7043); // Warm sunset
  static const Color skyBlue = Color(0xFF29B6F6); // Sky blue
  static const Color earthBrown = Color(0xFF795548); // Earth brown
  static const Color mountainGrey = Color(0xFF5A6268); // Mountain grey
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color lightText = Color(0xFF666666);
  static const Color borderGrey = Color(0xFFEEEEEE);
  
  // Difficulty Colors
  static const Color easyGreen = Color(0xFF66BB6A);
  static const Color moderateOrange = Color(0xFFFFA726);
  static const Color hardRed = Color(0xFFEF5350);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: secondaryGreen,
        tertiary: sunsetOrange,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: primaryGreen,
        foregroundColor: white,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: white,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: white),
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightGreen,
        labelStyle: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGreen,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: const TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: lightText),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkText,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkText,
          letterSpacing: 0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkText,
          letterSpacing: 0.2,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: darkText,
          letterSpacing: 0.1,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: lightText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: lightText,
        ),
      ),
    );
  }

  // Helper method for difficulty color
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return easyGreen;
      case 'moderate':
        return moderateOrange;
      case 'hard':
        return hardRed;
      default:
        return mountainGrey;
    }
  }

  // Helper method for gradient backgrounds
  static LinearGradient getHeroGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryGreen, secondaryGreen],
    );
  }

  static LinearGradient getSunsetGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [sunsetOrange, Color(0xFFFF5252)],
    );
  }
}
