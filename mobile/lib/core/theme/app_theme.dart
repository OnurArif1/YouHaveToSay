import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Uygulama geneli renk paleti (feed ekranı gradyanı).
class AppColors {
  AppColors._();

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF252547),
      Color(0xFF1A1A35),
      Color(0xFF12122A),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static const scaffold = Color(0xFF141428);
  static const primary = Color(0xFF7C6CFF);
  static const accentPink = Color(0xFFFF6584);
  static const accentGlow = Color(0xFF7C6CFF);
  static const title = Colors.white;
  static const subtitle = Color(0xFFE8E8F0);
  static const muted = Color(0xFF9A9AB0);
  static const surfaceCard = Color(0x1AFFFFFF);
  static const border = Color(0x33FFFFFF);
  static const inputFill = Color(0x14FFFFFF);
}

/// Geriye dönük uyumluluk.
typedef FeedTheme = AppColors;

class AppTheme {
  /// Tüm uygulama için tek koyu tema.
  static ThemeData app() {
    const scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accentPink,
      onSecondary: Colors.white,
      surface: AppColors.scaffold,
      onSurface: AppColors.title,
      error: Color(0xFFFF6B6B),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.scaffold,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.title,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: AppColors.title,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        iconTheme: IconThemeData(color: AppColors.title),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.title,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColors.title),
        bodyMedium: TextStyle(color: AppColors.subtitle),
        bodySmall: TextStyle(color: AppColors.muted),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        labelStyle: const TextStyle(color: AppColors.muted),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error.withValues(alpha: 0.8)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.title,
          backgroundColor: AppColors.surfaceCard,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(color: AppColors.title),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2A2A45),
        contentTextStyle: const TextStyle(color: AppColors.title),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E38),
        titleTextStyle: const TextStyle(
          color: AppColors.title,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(color: AppColors.subtitle, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @Deprecated('Use AppTheme.app()')
  static ThemeData light() => app();

  @Deprecated('Use AppTheme.app()')
  static ThemeData feed() => app();
}
