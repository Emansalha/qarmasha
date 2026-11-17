import 'package:flutter/material.dart';

/// ألوان التطبيق — ثيم داكن فاخر بلمسة برتقالية نارية.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFF6A3D);
  static const Color primaryDark = Color(0xFFE04E1A);
  static const Color accent = Color(0xFFFFB547);
  static const Color background = Color(0xFF1A1A1C);
  static const Color surface = Color(0xFF262628);
  static const Color surface2 = Color(0xFF323235);
  static const Color text = Color(0xFFF6F6F6);
  static const Color muted = Color(0xFF9B9B9B);
  static const Color border = Color(0xFF3A3A3D);
  static const Color success = Color(0xFF34C77B);
  static const Color cream = Color(0xFF323235);
  static const Color ink = Color(0xFF2C2C2F);

  static const LinearGradient fire = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFFFF8A4C), Color(0xFFFF5A1F)],
  );
}

const String kFont = 'Tajawal';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: kFont,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.text,
      ),
      canvasColor: AppColors.surface,
      dividerColor: AppColors.border,
      scaffoldBackgroundColor: AppColors.background,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: kFont,
          color: AppColors.text,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(fontFamily: kFont, color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.muted),
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
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: kFont,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// ظل ناعم موحّد للبطاقات.
List<BoxShadow> softShadow() => [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];

/// ظل ملوّن أعمق للعناصر البارزة.
List<BoxShadow> glowShadow([Color color = AppColors.primary]) => [
      BoxShadow(
        color: color.withValues(alpha: 0.35),
        blurRadius: 22,
        offset: const Offset(0, 10),
      ),
    ];

String money(double v, [String symbol = '₪']) {
  final s = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  return '$s $symbol';
}
