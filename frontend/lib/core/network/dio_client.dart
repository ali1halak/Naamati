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

/// Injects the [Authorization: Bearer <token>] header on every request
/// and handles 401 responses by clearing the stored token.
///
/// When a 401 is received the interceptor removes the invalid token from
/// [FlutterSecureStorage]. A refresh-token flow can be added here later.
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final Dio dio;

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
    if (err.response?.statusCode == 401) {
      // Token is invalid/expired — clear it so the app can redirect to login.
      await secureStorage.delete(key: StorageKeys.accessToken);
      await secureStorage.delete(key: StorageKeys.refreshToken);

      // TODO: Add token-refresh logic here before clearing, if required.
    }
    handler.next(err);
  }
}
