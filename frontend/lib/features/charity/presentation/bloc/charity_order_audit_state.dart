import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/charity_order_audit.dart';

class CharityOrderAuditState extends Equatable {
  final BlocStatus status;
  final String? errorMessage;
  final CharityOrderAudit? audit;

  const CharityOrderAuditState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.audit,
  });

  bool get isLoading => status == BlocStatus.loading;
  bool get isSuccess => status == BlocStatus.success;
  bool get isFailure => status == BlocStatus.failure;

  static const Object _unset = Object();

  CharityOrderAuditState copyWith({
    BlocStatus? status,
    Object? errorMessage = _unset,
    Object? audit = _unset,
  }) {
    return CharityOrderAuditState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      audit: identical(audit, _unset)
          ? this.audit
          : audit as CharityOrderAudit?,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, audit];
}
