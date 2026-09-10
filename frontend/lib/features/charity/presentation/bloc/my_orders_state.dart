import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../../donation/domain/entities/donation_request.dart';

/// The four filter chips on "الطلبات السابقة" — [active]/[cancelledGroup]
/// are convenience aliases the backend groups server-side
/// (`CharityRequestController::index`), since a charity's own orders are
/// never usefully filtered by one exact `RequestStatus` value alone.
enum MyOrdersStatusFilter {
  all,
  active,
  completed,
  cancelledGroup;

  String get label => switch (this) {
    MyOrdersStatusFilter.all => 'الكل',
    MyOrdersStatusFilter.active => 'نشطة',
    MyOrdersStatusFilter.completed => 'مكتملة',
    MyOrdersStatusFilter.cancelledGroup => 'ملغاة',
  };

  /// Value sent as `?status=`.
  String get wireValue => switch (this) {
    MyOrdersStatusFilter.all => 'all',
    MyOrdersStatusFilter.active => 'active',
    MyOrdersStatusFilter.completed => 'completed',
    MyOrdersStatusFilter.cancelledGroup => 'cancelled_group',
  };
}

class MyOrdersState extends Equatable {
  final BlocStatus status;
  final String? errorMessage;
  final List<DonationRequest> orders;
  final MyOrdersStatusFilter filter;

  /// 1-based page the current [orders] end at.
  final int currentPage;

  /// Total pages the backend reports.
  final int lastPage;

  /// Whether the next page is currently being fetched (infinite scroll).
  final bool isLoadingMore;

  const MyOrdersState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.orders = const [],
    this.filter = MyOrdersStatusFilter.all,
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
  });

  bool get isLoading => status == BlocStatus.loading;
  bool get isFailure => status == BlocStatus.failure;
  bool get isSuccess => status == BlocStatus.success;
  bool get isEmpty => isSuccess && orders.isEmpty;
  bool get hasMore => currentPage < lastPage;

  static const Object _unset = Object();

  MyOrdersState copyWith({
    BlocStatus? status,
    Object? errorMessage = _unset,
    List<DonationRequest>? orders,
    MyOrdersStatusFilter? filter,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return MyOrdersState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      orders: orders ?? this.orders,
      filter: filter ?? this.filter,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    orders,
    filter,
    currentPage,
    lastPage,
    isLoadingMore,
  ];
}
