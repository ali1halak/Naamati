import 'package:dio/dio.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Custom Exception Classes
// ─────────────────────────────────────────────────────────────────────────────

/// Thrown when a remote API returns an error response.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException(statusCode: $statusCode, message: $message)';
}

/// Thrown when local storage operations fail.
class CacheException implements Exception {
  final String message;
  final int? statusCode;

  const CacheException({required this.message, this.statusCode});

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Thrown when the device has no network connectivity.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException({
    this.message = 'No internet connection. Please check your network.',
    this.statusCode,
  });

  @override
  String toString() => 'NetworkException(message: $message)';
}

// ─────────────────────────────────────────────────────────────────────────────
// DioException → Custom Exception Mapper
// ─────────────────────────────────────────────────────────────────────────────

/// Maps a [DioException] to the appropriate custom [Exception].
///
/// Usage in a data-source try/catch:
/// ```dart
/// } on DioException catch (e) {
///   throw mapDioExceptionToCustomException(e);
/// }
/// ```
Exception mapDioExceptionToCustomException(DioException error) {
  final statusCode = error.response?.statusCode;

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return ServerException(
        message: 'Connection timed out. Please try again.',
        statusCode: statusCode,
      );

    case DioExceptionType.badResponse:
      return _mapBadResponse(error);

    case DioExceptionType.connectionError:
      return const NetworkException();

    case DioExceptionType.cancel:
      return ServerException(message: 'Request was cancelled.', statusCode: statusCode);

    case DioExceptionType.badCertificate:
      return ServerException(message: 'SSL certificate error.', statusCode: statusCode);

    case DioExceptionType.unknown:
    default:
      if (error.error != null && error.error.toString().contains('SocketException')) {
        return const NetworkException();
      }
      return ServerException(
        message: error.message ?? 'An unknown server error occurred.',
        statusCode: statusCode,
      );
  }
}

/// Interprets the HTTP status code from a [DioExceptionType.badResponse].
Exception _mapBadResponse(DioException error) {
  final statusCode = error.response?.statusCode;

  // Try to extract a message from the response body.
  String message;
  try {
    final data = error.response?.data;
    if (data is Map) {
      message = (data['message'] ?? data['error'] ?? error.message ?? 'Server error').toString();
    } else {
      message = error.message ?? 'Server error';
    }
  } catch (_) {
    message = error.message ?? 'Server error';
  }

  switch (statusCode) {
    case 400:
      return ServerException(
        message: message.isNotEmpty ? message : 'Bad request.',
        statusCode: statusCode,
      );
    case 401:
      return ServerException(message: 'Unauthorized. Please log in again.', statusCode: statusCode);
    case 403:
      return ServerException(
        message: 'You do not have permission to perform this action.',
        statusCode: statusCode,
      );
    case 404:
      return ServerException(
        message: 'The requested resource was not found.',
        statusCode: statusCode,
      );
    case 409:
      return ServerException(
        message: message.isNotEmpty ? message : 'Conflict error.',
        statusCode: statusCode,
      );
    case 422:
      return ServerException(
        message: message.isNotEmpty ? message : 'Unprocessable content.',
        statusCode: statusCode,
      );
    case 429:
      return ServerException(
        message: 'Too many requests. Please slow down.',
        statusCode: statusCode,
      );
    case 500:
    case 502:
    case 503:
      return ServerException(
        message: 'Server error. Please try again later.',
        statusCode: statusCode,
      );
    default:
      return ServerException(message: message, statusCode: statusCode);
  }
}
