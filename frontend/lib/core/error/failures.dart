import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures in the app.
///
/// Every failure carries a human-readable [message] and an optional
/// [statusCode] (e.g. HTTP status) for more granular handling.
abstract class Failure extends Equatable {
  /// Human-readable description of the failure.
  final String message;

  /// Optional HTTP (or other protocol) status code associated with the failure.
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// ─────────────────────────────────────────────────────────────────────────────
// Concrete Failures
// ─────────────────────────────────────────────────────────────────────────────

/// Failure originating from a remote API / server error.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Failure when reading from or writing to local storage.
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.statusCode});
}

/// Failure due to no or poor network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.statusCode,
  });
}

/// Failure due to invalid user input or request parameters.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.statusCode});
}

/// Catch-all failure for unexpected/unknown errors.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.statusCode,
  });
}
