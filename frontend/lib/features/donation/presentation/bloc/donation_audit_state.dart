import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/donation_audit.dart';

class DonationAuditState extends Equatable {
  final BlocStatus status;
  final String? errorMessage;
  final DonationAudit? audit;
  final bool isSubmittingRating;
  final String? ratingSuccessMessage;
  final String? ratingErrorMessage;

  const DonationAuditState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.audit,
    this.isSubmittingRating = false,
    this.ratingSuccessMessage,
    this.ratingErrorMessage,
  });

  bool get isLoading => status == BlocStatus.loading;
  bool get isSuccess => status == BlocStatus.success;
  bool get isFailure => status == BlocStatus.failure;

  /// Sentinel that lets [copyWith] distinguish "not provided" from "null".
  static const Object _unset = Object();

  DonationAuditState copyWith({
    BlocStatus? status,
    Object? errorMessage = _unset,
    Object? audit = _unset,
    bool? isSubmittingRating,
    Object? ratingSuccessMessage = _unset,
    Object? ratingErrorMessage = _unset,
  }) {
    return DonationAuditState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      audit: identical(audit, _unset) ? this.audit : audit as DonationAudit?,
      isSubmittingRating: isSubmittingRating ?? this.isSubmittingRating,
      ratingSuccessMessage: identical(ratingSuccessMessage, _unset)
          ? this.ratingSuccessMessage
          : ratingSuccessMessage as String?,
      ratingErrorMessage: identical(ratingErrorMessage, _unset)
          ? this.ratingErrorMessage
          : ratingErrorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    audit,
    isSubmittingRating,
    ratingSuccessMessage,
    ratingErrorMessage,
  ];
}
