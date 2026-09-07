import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../../donation/domain/entities/donation_request.dart';

/// Which mutation (if any) is currently in flight on the tracking screen.
enum OrderTrackingAction { confirmPickup, confirmDistribution }

class OrderTrackingState extends Equatable {
  /// Load status of the order itself.
  final BlocStatus status;
  final String? errorMessage;

  final DonationRequest? order;

  /// In-flight mutation — drives the step buttons' spinners.
  final OrderTrackingAction? actionInProgress;

  /// Error of the last failed mutation (shown as a snackbar).
  final String? actionErrorMessage;

  /// One-shot success message for snackbars.
  final String? successMessage;

  const OrderTrackingState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.order,
    this.actionInProgress,
    this.actionErrorMessage,
    this.successMessage,
  });

  bool get isLoading => status == BlocStatus.loading;
  bool get isFailure => status == BlocStatus.failure;
  bool get isSuccess => status == BlocStatus.success;

  /// Sentinel that lets [copyWith] distinguish "not provided" from "null".
  static const Object _unset = Object();

  OrderTrackingState copyWith({
    BlocStatus? status,
    Object? errorMessage = _unset,
    Object? order = _unset,
    Object? actionInProgress = _unset,
    Object? actionErrorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return OrderTrackingState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      order: identical(order, _unset) ? this.order : order as DonationRequest?,
      actionInProgress: identical(actionInProgress, _unset)
          ? this.actionInProgress
          : actionInProgress as OrderTrackingAction?,
      actionErrorMessage: identical(actionErrorMessage, _unset)
          ? this.actionErrorMessage
          : actionErrorMessage as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    order,
    actionInProgress,
    actionErrorMessage,
    successMessage,
  ];
}
