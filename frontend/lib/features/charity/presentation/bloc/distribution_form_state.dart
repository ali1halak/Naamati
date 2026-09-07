import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';

class DistributionFormState extends Equatable {
  final BlocStatus status;
  final String? errorMessage;

  const DistributionFormState({
    this.status = BlocStatus.initial,
    this.errorMessage,
  });

  bool get isSubmitting => status == BlocStatus.loading;
  bool get isFailure => status == BlocStatus.failure;
  bool get isSuccess => status == BlocStatus.success;

  static const Object _unset = Object();

  DistributionFormState copyWith({
    BlocStatus? status,
    Object? errorMessage = _unset,
  }) {
    return DistributionFormState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
