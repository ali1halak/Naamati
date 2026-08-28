import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography scale for the Naamati design system.
///
/// All [TextStyle]s reference [AppColors] and use the bundled **Alexandria**
/// font (registered in `pubspec.yaml` under the family name `Alexandria` and
/// set as the app-wide default in [AppTheme]). Use these constants inside
/// [AppTheme] and in widget code rather than creating ad-hoc styles.
abstract class AppTextStyles {
  // Internal helpers — only used inside this class.
  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    Color color = AppColors.textPrimaryLight,
    double? letterSpacing,
  }) => TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    color: color,
    letterSpacing: letterSpacing,
    fontFamily: 'Alexandria',
  );

  // ── Display ──────────────────────────────────────────────────────────────────

  /// 57 sp — use for hero banners / splash screens.
  static final TextStyle displayLarge = _base(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.25,
  );

  /// 45 sp — large display text.
  static final TextStyle displayMedium = _base(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  /// 36 sp.
  static final TextStyle displaySmall = _base(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ── Headline ─────────────────────────────────────────────────────────────────

  /// 32 sp — page/section headings.
  static final TextStyle headlineLarge = _base(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  /// 28 sp.
  static final TextStyle headlineMedium = _base(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
  );

  /// 24 sp.
  static final TextStyle headlineSmall = _base(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // ── Title ────────────────────────────────────────────────────────────────────

  /// 22 sp — card/dialog titles.
  static final TextStyle titleLarge = _base(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  /// 16 sp — list item titles.
  static final TextStyle titleMedium = _base(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
  );

  /// 14 sp.
  static final TextStyle titleSmall = _base(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // ── Body ─────────────────────────────────────────────────────────────────────

  /// 16 sp — primary reading text.
  static final TextStyle bodyLarge = _base(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textSecondaryLight,
  );

  /// 14 sp — secondary reading text.
  static final TextStyle bodyMedium = _base(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
    color: AppColors.textSecondaryLight,
  );

  /// 12 sp — captions, helper text.
  static final TextStyle bodySmall = _base(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
    color: AppColors.textSecondaryLight,
  );

  // ── Label ────────────────────────────────────────────────────────────────────

  /// 14 sp — button labels, chips.
  static final TextStyle labelLarge = _base(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  /// 12 sp — small badges, tooltips.
  static final TextStyle labelSmall = _base(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
  );
}
