import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/violation.dart';

class ViolationsState extends Equatable {
  final BlocStatus status;
  final String? errorMessage;
  final List<Violation> violations;
  final ComplianceInfo? compliance;

  /// 1-based page the current [violations] end at.
  final int currentPage;

  /// Total pages the backend reports.
  final int lastPage;

  /// Whether the next page is currently being fetched (infinite scroll).
  final bool isLoadingMore;

  const ViolationsState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.violations = const [],
    this.compliance,
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
  });

  bool get isLoading => status == BlocStatus.loading;
  bool get isFailure => status == BlocStatus.failure;
  bool get isSuccess => status == BlocStatus.success;
  bool get isEmpty => isSuccess && violations.isEmpty;
  bool get hasMore => currentPage < lastPage;

  static const Object _unset = Object();

  ViolationsState copyWith({
    BlocStatus? status,
    Object? errorMessage = _unset,
    List<Violation>? violations,
    Object? compliance = _unset,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return ViolationsState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      violations: violations ?? this.violations,
      compliance: identical(compliance, _unset)
          ? this.compliance
          : compliance as ComplianceInfo?,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    violations,
    compliance,
    currentPage,
    lastPage,
    isLoadingMore,
  ];
}
