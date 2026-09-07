import 'package:equatable/equatable.dart';

import 'available_request.dart';

/// One page of the charity's "available requests" marketplace, plus the
/// pagination metadata needed to know whether more pages follow.
class PaginatedAvailableRequests extends Equatable {
  final List<AvailableRequest> items;

  /// 1-based page number the [items] were fetched from.
  final int currentPage;

  /// Total number of pages the backend reports.
  final int lastPage;

  const PaginatedAvailableRequests({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  /// Whether another page can be requested after [currentPage].
  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [items, currentPage, lastPage];
}
