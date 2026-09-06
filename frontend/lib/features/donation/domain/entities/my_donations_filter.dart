import 'package:equatable/equatable.dart';

import 'donation_status.dart';

/// Active filter selection for the "تبرعاتي" list.
///
/// Every nullable field means "no filter on that dimension" — the backend
/// endpoint simply omits the corresponding query param.
class MyDonationsFilter extends Equatable {
  /// Free-text search matched against title/description/quantity/category
  /// name (backend `search` query param).
  final String? query;

  /// Lifecycle status filter (status chip row).
  final DonationStatus? status;

  /// Food category id (food_categories.id).
  final int? categoryId;

  /// Whether the food needs cooking (true) or is ready to serve (false).
  final bool? needsCooking;

  /// Inclusive lower bound on the donation creation date.
  final DateTime? fromDate;

  /// Inclusive upper bound on the donation creation date.
  final DateTime? toDate;

  const MyDonationsFilter({
    this.query,
    this.status,
    this.categoryId,
    this.needsCooking,
    this.fromDate,
    this.toDate,
  });

  /// No filtering at all.
  static const MyDonationsFilter empty = MyDonationsFilter();

  /// Whether any advanced (bottom-sheet) filter is set — drives the badge on
  /// the filter button.
  bool get hasAdvancedFilters =>
      categoryId != null ||
      needsCooking != null ||
      fromDate != null ||
      toDate != null;

  /// Whether anything is currently being filtered on.
  bool get hasActiveFilters => activeCount > 0;

  /// Number of dimensions currently filtered on.
  int get activeCount =>
      [query, status, categoryId, needsCooking, fromDate, toDate]
          .where((f) => f != null && (f is! String || f.isNotEmpty))
          .length;

  /// `from` in the backend's wire format (Y-m-d), or null.
  String? get fromWire => _wireDate(fromDate);

  /// `to` in the backend's wire format (Y-m-d), or null.
  String? get toWire => _wireDate(toDate);

  static String? _wireDate(DateTime? date) => date == null
      ? null
      : '${date.year.toString().padLeft(4, '0')}'
          '-${date.month.toString().padLeft(2, '0')}'
          '-${date.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [
    query,
    status,
    categoryId,
    needsCooking,
    fromDate,
    toDate,
  ];
}
