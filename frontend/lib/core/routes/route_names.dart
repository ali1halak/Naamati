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

  /// Donation audit details (Screen 2: تفاصيل التبرع).
  static const String donationAudit = '/donation/:id/audit';

  /// Edit form for a still-pending donation. The donation object travels
  /// via GoRouter `extra`.
  static const String donationEdit = '/donation/:id/edit';

  /// Convenience builder for [donationAudit] deep links.
  static String donationAuditPath(int id) => '/donation/$id/audit';

  // ── Charity (الجمعية) ─────────────────────────────────────────────────────────
  static const String charityHome = '/charity/home';

  /// Charity order tracking (قبول الطلب → تأكيد أخذ الطلب → تأكيد توزيع الطلب).
  static const String charityOrderTracking = '/charity/orders/:id';

  /// Convenience builder for [charityOrderTracking] deep links.
  static String charityOrderTrackingPath(int id) => '/charity/orders/$id';

  /// Distribution data form (بيانات التوزيع), filed now or later.
  static const String charityDistributionData =
      '/charity/orders/:id/distribution';

  /// Convenience builder for [charityDistributionData] deep links.
  static String charityDistributionDataPath(int id) =>
      '/charity/orders/$id/distribution';

  /// Read-only order audit (تفاصيل الطلب) — reached from "الطلبات السابقة".
  static const String charityOrderDetails = '/charity/orders/:id/details';

  /// Convenience builder for [charityOrderDetails] deep links.
  static String charityOrderDetailsPath(int id) =>
      '/charity/orders/$id/details';

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

  // ── Notifications ────────────────────────────────────────────────────────────
  /// Shared feed for both roles — the backend scopes rows to the caller.
  static const String notifications = '/notifications';

  // ── Error / Fallback ─────────────────────────────────────────────────────────
  static const String notFound = '/404';
}
