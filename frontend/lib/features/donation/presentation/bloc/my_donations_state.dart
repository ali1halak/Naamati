import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/donation_request.dart';

class MyDonationsState extends Equatable {
  final BlocStatus status;
  final String? errorMessage;
  final List<DonationRequest> donations;

  const MyDonationsState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.donations = const [],
  });

  bool get isLoading => status == BlocStatus.loading;
  bool get isFailure => status == BlocStatus.failure;
  bool get isSuccess => status == BlocStatus.success;
  bool get isEmpty => isSuccess && donations.isEmpty;

  /// Sentinel that lets [copyWith] distinguish "not provided" from "null".
  static const Object _unset = Object();

  MyDonationsState copyWith({
    BlocStatus? status,
    Object? errorMessage = _unset,
    List<DonationRequest>? donations,
  }) {
    return MyDonationsState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      donations: donations ?? this.donations,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, donations];
}
