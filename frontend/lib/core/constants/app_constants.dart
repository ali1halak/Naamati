/// Application-wide constants that are NOT environment-specific.
///
/// Centralising these values makes global design tweaks a single-line change.
abstract class AppConstants {
  // ── App Identity ────────────────────────────────────────────────────────────
  static const String appName = 'Naamati';
  static const String appVersion = '1.0.0';

  // ── Spacing / Padding / Margin ───────────────────────────────────────────────
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  static const double marginXS = 4.0;
  static const double marginSM = 8.0;
  static const double marginMD = 16.0;
  static const double marginLG = 24.0;
  static const double marginXL = 32.0;

  // ── Border Radius ────────────────────────────────────────────────────────────
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircular = 999.0;

  // ── Animation Durations ──────────────────────────────────────────────────────
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  // ── UI ───────────────────────────────────────────────────────────────────────
  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;
  static const double iconSizeSM = 16.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 32.0;
  static const double appBarHeight = 56.0;
}
