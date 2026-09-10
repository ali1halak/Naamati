import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/available_request.dart';

class AvailableRequestsState extends Equatable {
  final BlocStatus status;
  final String? errorMessage;
  final List<AvailableRequest> requests;

  /// Free-text search currently applied.
  final String? search;

  /// 1-based page the current [requests] end at.
  final int currentPage;

  /// Total pages the backend reports.
  final int lastPage;

  /// Total number of available requests across all pages — bottom nav badge.
  final int total;

  /// Whether the next page is currently being fetched (infinite scroll).
  final bool isLoadingMore;

  /// Id of the request whose "accept" call is in flight, or null.
  final int? acceptingId;

  /// Error of the last failed accept attempt (shown via a snackbar).
  final String? acceptErrorMessage;

  const AvailableRequestsState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.requests = const [],
    this.search,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.isLoadingMore = false,
    this.acceptingId,
    this.acceptErrorMessage,
  });

  bool get isLoading => status == BlocStatus.loading;
  bool get isFailure => status == BlocStatus.failure;
  bool get isSuccess => status == BlocStatus.success;
  bool get isEmpty => isSuccess && requests.isEmpty;

  /// Whether another page can be requested.
  bool get hasMore => currentPage < lastPage;

  /// Sentinel that lets [copyWith] distinguish "not provided" from "null".
  static const Object _unset = Object();

  AvailableRequestsState copyWith({
    BlocStatus? status,
    Object? errorMessage = _unset,
    List<AvailableRequest>? requests,
    Object? search = _unset,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingMore,
    Object? acceptingId = _unset,
    Object? acceptErrorMessage = _unset,
  }) {
    return AvailableRequestsState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      requests: requests ?? this.requests,
      search: identical(search, _unset) ? this.search : search as String?,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      acceptingId: identical(acceptingId, _unset)
          ? this.acceptingId
          : acceptingId as int?,
      acceptErrorMessage: identical(acceptErrorMessage, _unset)
          ? this.acceptErrorMessage
          : acceptErrorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    requests,
    search,
    currentPage,
    lastPage,
    total,
    isLoadingMore,
    acceptingId,
    acceptErrorMessage,
  ];
}
