/// Shared state markers for feature Blocs/Cubits.
///
/// Feature-level state classes can mix in or extend these markers so that
/// generic UI components (loading indicator, error widget) can react to
/// states without knowing about specific feature internals.
///
/// Example:
/// ```dart
/// class ProductsState extends Equatable {
///   // ...
/// }
///
/// class ProductsLoading extends ProductsState with BlocLoadingState {}
/// class ProductsSuccess extends ProductsState with BlocSuccessState {}
/// class ProductsError extends ProductsState with BlocErrorState {
///   @override
///   final String errorMessage;
///   ProductsError(this.errorMessage);
/// }
/// ```
library;

// ─────────────────────────────────────────────────────────────────────────────
// Marker Mixins
// ─────────────────────────────────────────────────────────────────────────────

/// Mixin that marks a Bloc state as representing an in-progress operation.
mixin BlocLoadingState {}

/// Mixin that marks a Bloc state as representing a successful operation.
mixin BlocSuccessState {}

/// Mixin that marks a Bloc state as representing a failed operation.
///
/// Implementors must provide a human-readable [errorMessage].
mixin BlocErrorState {
  String get errorMessage;
}

/// Mixin that marks a Bloc state as the initial / empty state.
mixin BlocInitialState {}

// ─────────────────────────────────────────────────────────────────────────────
// Abstract Base State (optional — use if you prefer inheritance over mixins)
// ─────────────────────────────────────────────────────────────────────────────

/// Abstract base for typed Bloc states that carry one of four status values.
///
/// Prefer using the marker mixins above for more compositional flexibility.
enum BlocStatus { initial, loading, success, failure }

/// A lightweight base state carrying a [BlocStatus].
///
/// Extend this class when all states in a Cubit share common fields
/// (e.g. an error message or a loading flag).
abstract class BaseState {
  final BlocStatus status;
  final String? errorMessage;

  const BaseState({this.status = BlocStatus.initial, this.errorMessage});

  /// Whether the state represents an active loading operation.
  bool get isLoading => status == BlocStatus.loading;

  /// Whether the state represents a successful outcome.
  bool get isSuccess => status == BlocStatus.success;

  /// Whether the state represents a failure.
  bool get isFailure => status == BlocStatus.failure;

  /// Whether this is the initial/untouched state.
  bool get isInitial => status == BlocStatus.initial;
}
