/// Route path and name constants used with [GoRouter].
///
/// Keeping paths in one place prevents typos and simplifies refactoring
/// when routes need to be renamed or nested differently.
abstract class RouteNames {
  // ── Root / Shell ─────────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String home = '/home';

  // ── Auth ─────────────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';

  // ── Onboarding ───────────────────────────────────────────────────────────────
  static const String onboarding = '/onboarding';

  // ── Profile ──────────────────────────────────────────────────────────────────
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  // ── Settings ─────────────────────────────────────────────────────────────────
  static const String settings = '/settings';

  // ── Error / Fallback ─────────────────────────────────────────────────────────
  static const String notFound = '/404';
}
