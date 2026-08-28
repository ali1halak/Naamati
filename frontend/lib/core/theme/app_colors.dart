import 'package:flutter/material.dart';

/// All color tokens used across the app.
///
/// Use these constants inside [AppTheme] and directly in widget code — never
/// hard-code color literals anywhere else.
abstract class AppColors {
  // ── Brand / Primary (Naamati green) ──────────────────────────────────────────
  static const Color primary = brandGreen;
  static const Color primaryLight = Color(0xFF9DC8AF);
  static const Color primaryDark = Color(0xFF142F22);
  static const Color primaryContainer = Color(0xFFDDEAE2);

  // ── Brand / Naamati Green (actual app brand) ────────────────────────────────
  /// Primary green used for the app bar, headings and buttons.
  static const Color brandGreen = Color(0xFF1E4632);

  /// Light beige background used on the login/auth screens.
  static const Color brandBeige = Color(0xFFF9F7F3);

  // ── Secondary / Accent (warm gold — complements the green/beige brand) ───────
  static const Color secondary = Color(0xFFB8862F);
  static const Color secondaryLight = Color(0xFFD4A94F);
  static const Color secondaryDark = Color(0xFF8F6720);
  static const Color secondaryContainer = Color(0xFFF7EDD6);

  // ── Semantic ─────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2DA77E);
  static const Color successLight = Color(0xFF7AD4B6);
  static const Color successContainer = Color(0xFFDEF4EC);

  static const Color warning = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFDE68A);
  static const Color warningContainer = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFCA5A5);
  static const Color errorContainer = Color(0xFFFEE2E2);

  // ── Neutral / Light Theme ────────────────────────────────────────────────────
  static const Color backgroundLight = brandBeige;
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1EEE7);
  static const Color outlineLight = Color(0xFFD9D4C9);

  static const Color textPrimaryLight = Color(0xFF1C2420);
  static const Color textSecondaryLight = Color(0xFF5C6B62);
  static const Color textDisabledLight = Color(0xFFBDBDBD);
  static const Color textHintLight = Color(0xFF9CA3AF);

  // ── Neutral / Dark Theme (green-tinted to stay on-brand) ─────────────────────
  static const Color backgroundDark = Color(0xFF0F1613);
  static const Color surfaceDark = Color(0xFF17211C);
  static const Color surfaceVariantDark = Color(0xFF232F29);
  static const Color outlineDark = Color(0xFF35453C);

  static const Color textPrimaryDark = Color(0xFFEDF3EF);
  static const Color textSecondaryDark = Color(0xFFA4B6AC);
  static const Color textDisabledDark = Color(0xFF6B7280);
  static const Color textHintDark = Color(0xFF75867D);

  // ── Misc ─────────────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF27342D);
  static const Color shadow = Color(0x14000000);
  static const Color overlay = Color(0x4D000000);
}
