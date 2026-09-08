import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DioClient
// ─────────────────────────────────────────────────────────────────────────────

/// Factory that builds and configures a [Dio] instance for the app.
///
/// Do NOT create [Dio] instances directly in data-sources — always inject
/// this configured instance via [GetIt] so interceptors apply globally.
class DioClient {
  DioClient._();

  /// Creates a fully configured [Dio] instance.
  ///
  /// - Sets base URL, connection/receive timeouts and default headers.
  /// - Attaches [LogInterceptor] only in debug builds.
  /// - Attaches [_AuthInterceptor] which reads/refreshes the Bearer token.
  static Dio create(FlutterSecureStorage secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          ApiConstants.headerContentType: ApiConstants.contentTypeJson,
          ApiConstants.headerAccept: ApiConstants.contentTypeJson,
        },
        responseType: ResponseType.json,
      ),
    );

    // Logging — debug only.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint('[DIO] $obj'),
        ),
      );
    }

    // Auth token injection + 401 handling.
    dio.interceptors.add(
      _AuthInterceptor(secureStorage: secureStorage, dio: dio),
    );

    return dio;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthInterceptor
// ─────────────────────────────────────────────────────────────────────────────

/// Injects the [Authorization: Bearer <token>] header on every request and
/// handles 401s by exchanging the stored refresh token for a fresh pair.
///
/// The backend rotates the pair on every refresh (the presented refresh token
/// is destroyed), so concurrent 401s must share a single refresh call — that
/// is what [_refreshing] provides. When refreshing fails (expired/absent
/// refresh token) both stored tokens are cleared so the app can route back
/// to login.
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final Dio dio;

  /// Shared in-flight refresh, so parallel 401s reuse one rotation instead of
  /// each presenting the same (single-use) refresh token.
  Future<bool>? _refreshing;

  _AuthInterceptor({required this.secureStorage, required this.dio});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.read(key: StorageKeys.accessToken);
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.headerAuthorization] =
          '${ApiConstants.bearerPrefix}$token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final isRefreshCall =
        err.requestOptions.uri.path.endsWith(ApiConstants.pathRefreshToken);
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (response?.statusCode != 401 || isRefreshCall || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshTokens();
    if (!refreshed) {
      // Refresh token missing/expired — session is over, drop everything.
      await secureStorage.delete(key: StorageKeys.accessToken);
      await secureStorage.delete(key: StorageKeys.refreshToken);
      handler.next(err);
      return;
    }

    try {
      final newToken = await secureStorage.read(key: StorageKeys.accessToken);
      final options = err.requestOptions
        ..headers[ApiConstants.headerAuthorization] =
            '${ApiConstants.bearerPrefix}$newToken'
        ..extra['retried'] = true;

      final retryResponse = await dio.fetch(options);
      handler.resolve(retryResponse);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }

  /// Rotates the token pair once; concurrent callers await the same future.
  ///
  /// Returns true when a fresh access token is in storage afterwards.
  Future<bool> _refreshTokens() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await secureStorage.read(
      key: StorageKeys.refreshToken,
    );
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      // A bare Dio on purpose: no interceptors, so this call can never
      // recurse into the refresh flow itself.
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
          headers: {
            ApiConstants.headerContentType: ApiConstants.contentTypeJson,
            ApiConstants.headerAccept: ApiConstants.contentTypeJson,
            ApiConstants.headerAuthorization:
                '${ApiConstants.bearerPrefix}$refreshToken',
          },
        ),
      );

      final response = await refreshDio.post(ApiConstants.pathRefreshToken);
      final data = response.data['data'];
      final newAccess = data?['access_token'] as String?;
      final newRefresh = data?['refresh_token'] as String?;
      if (newAccess == null || newAccess.isEmpty) return false;

      // Persist before anything else — the old pair is already dead server-side.
      await secureStorage.write(
        key: StorageKeys.accessToken,
        value: newAccess,
      );
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await secureStorage.write(
          key: StorageKeys.refreshToken,
          value: newRefresh,
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
