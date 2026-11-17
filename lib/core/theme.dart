import 'package:flutter/material.dart';

/// ألوان التطبيق — أحمر دافئ وكريمي يفتح الشهية.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFD62828);
  static const Color primaryDark = Color(0xFF9B1C1C);
  static const Color accent = Color(0xFFF7B32B);
  static const Color background = Color(0xFFFFF8F1);
  static const Color surface = Colors.white;
  static const Color text = Color(0xFF2B1D1A);
  static const Color muted = Color(0xFF8A7B75);
  static const Color border = Color(0xFFF1E4DA);
  static const Color success = Color(0xFF2E9E5B);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.text,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// ظل ناعم موحّد للبطاقات.
List<BoxShadow> softShadow() => [
      BoxShadow(
        color: const Color(0xFF9B1C1C).withValues(alpha: 0.07),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];

String money(double v, [String symbol = '₪']) {
  final s = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  return '$s $symbol';
}
