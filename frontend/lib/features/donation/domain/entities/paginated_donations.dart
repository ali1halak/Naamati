import 'package:equatable/equatable.dart';

import 'donation_request.dart';

/// One page of the donor's donations list plus the pagination metadata
/// needed to know whether more pages follow.
class PaginatedDonations extends Equatable {
  final List<DonationRequest> items;

  /// 1-based page number the [items] were fetched from.
  final int currentPage;

  /// Total number of pages the backend reports.
  final int lastPage;

  /// Total number of donations across all pages.
  final int total;

  const PaginatedDonations({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  /// Whether another page can be requested after [currentPage].
  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [items, currentPage, lastPage, total];
}
