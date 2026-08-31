/// Route path and name constants used with [GoRouter].
///
/// Keeping paths in one place prevents typos and simplifies refactoring
/// when routes need to be renamed or nested differently.
abstract class RouteNames {
  // ── Root / Shell ─────────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String welcome = '/welcome';

  // ── Donor (المتبرع) ────────────────────────────────────────────────────────────
  /// Donor-only home — matches the Figma screenshot (طلب تبرع جديد).
  static const String home = '/home';
  static const String donorHome = '/home';

  // ── Donations (التبرعات) ──────────────────────────────────────────────────────
  /// Create-donation form. Must stay above [donationDetails] so the static
  /// path wins over the `:id` parameter route.
  static const String createDonation = '/donation/new';

  /// Donation tracking (pending → accepted → delivered → rated).
  static const String donationDetails = '/donation/:id';

  /// Convenience builder for [donationDetails] deep links.
  static String donationDetailsPath(int id) => '/donation/$id';

  // ── Charity (الجمعية) ─────────────────────────────────────────────────────────
  static const String charityHome = '/charity/home';

  // ── Auth ─────────────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String resetPassword = '/reset-password';
  static const String charityPending = '/charity/pending';
  static const String charitySuspended = '/charity/suspended';

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
