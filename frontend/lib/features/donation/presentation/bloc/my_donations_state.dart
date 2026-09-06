import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/donation_request.dart';
import '../../domain/entities/my_donations_filter.dart';

class MyDonationsState extends Equatable {
  final BlocStatus status;

  /// Filter selection the current [donations] were fetched with.
  final MyDonationsFilter filter;

  final String? errorMessage;
  final List<DonationRequest> donations;

  /// 1-based page the current [donations] end at.
  final int currentPage;

  /// Total pages the backend reports for [filter].
  final int lastPage;

  /// Whether the next page is currently being fetched (infinite scroll).
  final bool isLoadingMore;

  /// Id of the donation whose cancel request is in flight, or null.
  final int? cancellingId;

  const MyDonationsState({
    this.status = BlocStatus.initial,
    this.filter = MyDonationsFilter.empty,
    this.errorMessage,
    this.donations = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.cancellingId,
  });

  bool get isLoading => status == BlocStatus.loading;

  /// Re-fetch in the background while a previous list is still on screen.
  bool get isRefining => isLoading && donations.isNotEmpty;

  bool get isFailure => status == BlocStatus.failure;
  bool get isSuccess => status == BlocStatus.success;
  bool get isEmpty => isSuccess && donations.isEmpty;

  /// Whether another page of the current filter can be requested.
  bool get hasMore => currentPage < lastPage;

  /// Sentinel that lets [copyWith] distinguish "not provided" from "null".
  static const Object _unset = Object();

  MyDonationsState copyWith({
    BlocStatus? status,
    MyDonationsFilter? filter,
    Object? errorMessage = _unset,
    List<DonationRequest>? donations,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
    Object? cancellingId = _unset,
  }) {
    return MyDonationsState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      donations: donations ?? this.donations,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      cancellingId: identical(cancellingId, _unset)
          ? this.cancellingId
          : cancellingId as int?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    filter,
    errorMessage,
    donations,
    currentPage,
    lastPage,
    isLoadingMore,
    cancellingId,
  ];
}
