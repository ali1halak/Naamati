import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Constants related to the remote API layer.
///
/// Feature-specific endpoint paths should be defined alongside their
/// data-sources, not here.
abstract class ApiConstants {
  // ── Base URL ─────────────────────────────────────────────────────────────────
  /// Loads the API base URL from the .env file.
  ///
  /// The Laravel API is served under `/api/v1`, so the base URL must include
  /// the version prefix (e.g. `http://localhost:8000/api/v1`).
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1';

  // ── Timeouts ─────────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ── Common Header Keys ───────────────────────────────────────────────────────
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerAuthorization = 'Authorization';
  static const String headerAcceptLanguage = 'Accept-Language';

  // ── Common Header Values ─────────────────────────────────────────────────────
  static const String contentTypeJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';

  // ── Common Endpoint Path Segments ────────────────────────────────────────────
  static const String pathLogin = '/login';
  static const String pathRegister = '/register';
  static const String pathRefreshToken = '/refresh';
  static const String pathLogout = '/logout';
  static const String pathMe = '/me';
  static const String pathProfile = '/profile';
}
