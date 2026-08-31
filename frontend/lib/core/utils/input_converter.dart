import 'package:dartz/dartz.dart';

import '../error/failures.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InputConverter
// ─────────────────────────────────────────────────────────────────────────────

/// Safely converts and validates raw string input into typed values.
///
/// Returns [Right] with the converted value on success, or [Left] with a
/// [ValidationFailure] on failure — keeping the repository layer clean.
class InputConverter {
  /// Converts [str] to a non-negative [int].
  ///
  /// Returns [Left<ValidationFailure>] if [str] is not a valid integer
  /// or is negative.
  Either<Failure, int> stringToUnsignedInt(String str) {
    try {
      final value = int.parse(str);
      if (value < 0) {
        return Left(const ValidationFailure(message: 'Value must be a positive number.'));
      }
      return Right(value);
    } on FormatException {
      return Left(const ValidationFailure(message: 'Invalid number format.'));
    }
  }

  /// Converts [str] to a [double].
  ///
  /// Returns [Left<ValidationFailure>] if parsing fails.
  Either<Failure, double> stringToDouble(String str) {
    try {
      return Right(double.parse(str));
    } on FormatException {
      return Left(const ValidationFailure(message: 'Invalid decimal number format.'));
    }
  }

  /// Trims [str] and checks it is non-empty.
  ///
  /// Returns [Left<ValidationFailure>] if empty after trimming.
  Either<Failure, String> stringNotEmpty(String str) {
    final trimmed = str.trim();
    if (trimmed.isEmpty) {
      return Left(const ValidationFailure(message: 'This field cannot be empty.'));
    }
    return Right(trimmed);
  }
}
