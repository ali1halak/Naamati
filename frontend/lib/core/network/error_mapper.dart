import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';

/// Maps any caught exception to the appropriate [Failure] subclass.
///
/// Call this inside repository `catch` blocks so that domain-layer callers
/// receive a typed [Failure] rather than raw exceptions:
///
/// ```dart
/// } catch (e) {
///   return Left(mapExceptionToFailure(e));
/// }
/// ```
Failure mapExceptionToFailure(Object exception) {
  if (exception is ServerException) {
    return ServerFailure(
      message: exception.message,
      statusCode: exception.statusCode,
    );
  }

  if (exception is CacheException) {
    return CacheFailure(
      message: exception.message,
      statusCode: exception.statusCode,
    );
  }

  if (exception is NetworkException) {
    return NetworkFailure(
      message: exception.message,
      statusCode: exception.statusCode,
    );
  }

  if (exception is DioException) {
    // Convert to a custom exception first, then recurse.
    final customException = mapDioExceptionToCustomException(exception);
    return mapExceptionToFailure(customException);
  }

  // Fallback for any truly unexpected exception.
  return UnknownFailure(message: exception.toString());
}
