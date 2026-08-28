/// Keys used to read/write values in [SharedPreferences] (or secure storage).
///
/// Keeping all keys here prevents typos and naming collisions when
/// multiple parts of the app access the same stored value.
abstract class StorageKeys {
  // ── Auth ─────────────────────────────────────────────────────────────────────
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiry = 'token_expiry';

  // ── User ─────────────────────────────────────────────────────────────────────
  static const String currentUser = 'current_user';
  static const String userId = 'user_id';

  // ── Onboarding / App State ───────────────────────────────────────────────────
  static const String isOnboardingComplete = 'is_onboarding_complete';
  static const String isFirstLaunch = 'is_first_launch';

  // ── Preferences ──────────────────────────────────────────────────────────────
  static const String appLocale = 'app_locale';
  static const String appThemeMode = 'app_theme_mode';
  static const String notificationsEnabled = 'notifications_enabled';
}
