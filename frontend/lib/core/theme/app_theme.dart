import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Full [ThemeData] definitions for light and dark modes.
///
/// Consumes [AppColors] and [AppTextStyles] — do NOT hard-code any color
/// or text-style value here.
abstract class AppTheme {
  // ─────────────────────────────────────────────────────────────────────────────
  // Light Theme
  // ─────────────────────────────────────────────────────────────────────────────

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Alexandria',
    colorScheme: _lightColorScheme,
    textTheme: _textTheme(isLight: true),
    appBarTheme: _appBarTheme(isLight: true),
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    inputDecorationTheme: _inputDecorationTheme(isLight: true),
    cardTheme: _cardTheme(isLight: true),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    splashFactory: InkRipple.splashFactory,
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Dark Theme
  // ─────────────────────────────────────────────────────────────────────────────

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Alexandria',
    colorScheme: _darkColorScheme,
    textTheme: _textTheme(isLight: false),
    appBarTheme: _appBarTheme(isLight: false),
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    inputDecorationTheme: _inputDecorationTheme(isLight: false),
    cardTheme: _cardTheme(isLight: false),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    splashFactory: InkRipple.splashFactory,
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // ColorScheme
  // ─────────────────────────────────────────────────────────────────────────────

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.secondaryDark,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.secondaryDark,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    surfaceContainerHighest: AppColors.surfaceVariantLight,
    onSurfaceVariant: AppColors.textSecondaryLight,
    outline: AppColors.outlineLight,
    shadow: AppColors.shadow,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    onPrimary: AppColors.primaryDark,
    primaryContainer: AppColors.surfaceVariantDark,
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.secondaryDark,
    secondaryContainer: AppColors.secondaryDark,
    onSecondaryContainer: AppColors.secondaryContainer,
    error: AppColors.errorLight,
    onError: AppColors.primaryDark,
    errorContainer: AppColors.secondaryDark,
    onErrorContainer: AppColors.errorLight,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.outlineDark,
    shadow: Colors.black,
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // TextTheme
  // ─────────────────────────────────────────────────────────────────────────────

  static TextTheme _textTheme({required bool isLight}) {
    final primary = isLight
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;
    final secondary = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(color: primary),
      displayMedium: AppTextStyles.displayMedium.copyWith(color: primary),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: primary),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: primary),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: primary),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: primary),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: primary),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: primary),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: primary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: secondary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: secondary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: secondary),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: primary),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: secondary),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // AppBarTheme
  // ─────────────────────────────────────────────────────────────────────────────

  static AppBarTheme _appBarTheme({required bool isLight}) => AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: true,
    backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
    foregroundColor: isLight
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark,
    titleTextStyle: AppTextStyles.titleLarge.copyWith(
      color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
    ),
    iconTheme: IconThemeData(
      color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
      size: 24,
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // Button Themes
  // ─────────────────────────────────────────────────────────────────────────────

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryLight.withValues(
            alpha: 0.4,
          ),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge,
          elevation: 0,
        ),
      );

  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      );

  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: AppTextStyles.labelLarge,
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────────
  // InputDecorationTheme
  // ─────────────────────────────────────────────────────────────────────────────

  static InputDecorationTheme _inputDecorationTheme({required bool isLight}) =>
      InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? AppColors.surfaceVariantLight
            : AppColors.surfaceVariantDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: isLight ? AppColors.textHintLight : AppColors.textHintDark,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: isLight
              ? AppColors.textSecondaryLight
              : AppColors.textSecondaryDark,
        ),
      );

  // ─────────────────────────────────────────────────────────────────────────────
  // CardTheme
  // ─────────────────────────────────────────────────────────────────────────────

  static CardThemeData _cardTheme({required bool isLight}) => CardThemeData(
    color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
        width: 1,
      ),
    ),
    margin: EdgeInsets.zero,
  );
}
