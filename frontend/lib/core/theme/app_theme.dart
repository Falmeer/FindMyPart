import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Inter';

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: _fontFamily,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          titleTextStyle: TextStyle(
            fontFamily: _fontFamily,
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 12,
          selectedLabelStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 52),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariant,
          selectedColor: AppColors.primaryLight,
          labelStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: const BorderSide(color: AppColors.border),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderLight,
          thickness: 1,
          space: 1,
        ),
        textTheme: _textTheme(AppColors.textPrimary, AppColors.textSecondary),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: _fontFamily,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
          titleTextStyle: TextStyle(
            fontFamily: _fontFamily,
            color: AppColors.textPrimaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.borderDark),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariantDark,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          hintStyle: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),
        textTheme: _textTheme(AppColors.textPrimaryDark, AppColors.textSecondaryDark),
      );

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: primary),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: primary),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: primary),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
        titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: primary),
        bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: secondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primary),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: secondary),
      );
}
