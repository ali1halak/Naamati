import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UseCase abstractions
// ─────────────────────────────────────────────────────────────────────────────

/// Contract for every synchronous use-case (returns a [Future]).
///
/// [T] is the success type; [Params] is the input parameter object.
/// Returns [Either<Failure, T>] to force explicit error handling.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Contract for streaming use-cases (e.g. real-time data feeds).
///
/// [T] is the emitted value type; [Params] is the input parameter object.
abstract class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper parameter types
// ─────────────────────────────────────────────────────────────────────────────

/// Use as the [Params] type for use-cases that require no input.
///
/// Example:
/// ```dart
/// class GetCurrentUser extends UseCase<User, NoParams> { … }
/// ```
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
