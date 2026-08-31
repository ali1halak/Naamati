import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/donation_request.dart';

/// Which mutation (if any) is currently in flight on the details screen.
enum DonationAction { cancel, confirmPickup, rate }

class DonationDetailsState extends Equatable {
  /// Load status of the donation itself.
  final BlocStatus status;
  final String? errorMessage;

  final DonationRequest? donation;

  /// In-flight mutation — drives button spinners in the UI.
  final DonationAction? actionInProgress;

  /// Error of the last failed mutation (shown inside sheets/dialogs).
  final String? actionErrorMessage;

  /// One-shot success message for snackbars (cleared via [consumeSuccessMessage]).
  final String? successMessage;

  const DonationDetailsState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.donation,
    this.actionInProgress,
    this.actionErrorMessage,
    this.successMessage,
  });

  bool get isLoading => status == BlocStatus.loading;
  bool get isFailure => status == BlocStatus.failure;
  bool get isSuccess => status == BlocStatus.success;

  /// Sentinel that lets [copyWith] distinguish "not provided" from "null".
  static const Object _unset = Object();

  DonationDetailsState copyWith({
    BlocStatus? status,
    Object? errorMessage = _unset,
    Object? donation = _unset,
    Object? actionInProgress = _unset,
    Object? actionErrorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return DonationDetailsState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      donation: identical(donation, _unset) ? this.donation : donation as DonationRequest?,
      actionInProgress: identical(actionInProgress, _unset)
          ? this.actionInProgress
          : actionInProgress as DonationAction?,
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
    donation,
    actionInProgress,
    actionErrorMessage,
    successMessage,
  ];
}
