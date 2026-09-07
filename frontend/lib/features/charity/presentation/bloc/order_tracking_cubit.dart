import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../../donation/domain/entities/donation_status.dart';
import '../../domain/usecases/confirm_distribution_usecase.dart';
import '../../domain/usecases/confirm_pickup_usecase.dart';
import '../../domain/usecases/get_order_details_usecase.dart';
import 'order_tracking_state.dart';

/// Cubit behind the charity's order-tracking screen ("متابعة الطلب").
///
/// [startAutoRefresh] polls every 15s while the order is still active, so the
/// donor's half of the two-sided handover confirmation reflects on screen
/// without a manual pull-to-refresh — mirrors the donor-side tracking cubit.
@injectable
class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  final GetOrderDetailsUseCase _getOrderDetailsUseCase;
  final ConfirmPickupUseCase _confirmPickupUseCase;
  final ConfirmDistributionUseCase _confirmDistributionUseCase;

  OrderTrackingCubit(
    this._getOrderDetailsUseCase,
    this._confirmPickupUseCase,
    this._confirmDistributionUseCase,
  ) : super(const OrderTrackingState());

  static const Duration pollInterval = Duration(seconds: 15);
  Timer? _pollTimer;
  bool _refreshing = false;

  /// Drops updates that arrive after the cubit closed (page popped mid-request,
  /// or the poll timer raced the provider).
  void _emit(OrderTrackingState state) {
    if (isClosed) return;
    emit(state);
  }

  /// Full load — shows the page-level loading state.
  Future<void> load(int id) async {
    _emit(state.copyWith(status: BlocStatus.loading, errorMessage: null));

    final result = await _getOrderDetailsUseCase(GetOrderDetailsParams(id: id));

    result.fold(
      (failure) => _emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (order) =>
          _emit(state.copyWith(status: BlocStatus.success, order: order)),
    );
  }

  /// Silent refresh — keeps the current order on screen while updating.
  Future<void> refresh() async {
    final order = state.order;
    if (order == null || _refreshing) return;
    _refreshing = true;
    try {
      final result = await _getOrderDetailsUseCase(
        GetOrderDetailsParams(id: order.id),
      );
      result.fold(
        // Silent failures keep the last known order (e.g. flaky network).
        (_) {},
        (updated) => _emit(state.copyWith(order: updated)),
      );
    } finally {
      _refreshing = false;
    }
  }

  void startAutoRefresh() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(pollInterval, (_) {
      final order = state.order;
      if (order != null && order.status.isActive && !_refreshing) {
        refresh();
      }
    });
  }

  void stopAutoRefresh() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ── Mutations ───────────────────────────────────────────────────────────────

  Future<void> confirmPickup() async {
    final order = state.order;
    if (order == null) return;

    _emit(
      state.copyWith(
        actionInProgress: OrderTrackingAction.confirmPickup,
        actionErrorMessage: null,
      ),
    );
    final result = await _confirmPickupUseCase(
      ConfirmPickupParams(id: order.id),
    );

    result.fold(
      (failure) => _emit(
        state.copyWith(
          actionInProgress: null,
          actionErrorMessage: failure.message,
        ),
      ),
      (updated) => _emit(
        state.copyWith(
          actionInProgress: null,
          order: updated,
          // The order only becomes picked_up once the donor confirms too —
          // still `accepted` on the wire means we are the first to confirm.
          successMessage: updated.status == DonationStatus.pickedUp
              ? 'تم تأكيد استلام الطعام'
              : 'تم تسجيل تأكيدك، بانتظار تأكيد المتبرع',
        ),
      ),
    );
  }

  /// Returns true on success, so the page can navigate to the distribution
  /// data form right after.
  Future<bool> confirmDistribution() async {
    final order = state.order;
    if (order == null) return false;

    _emit(
      state.copyWith(
        actionInProgress: OrderTrackingAction.confirmDistribution,
        actionErrorMessage: null,
      ),
    );
    final result = await _confirmDistributionUseCase(
      ConfirmDistributionParams(id: order.id),
    );

    bool ok = false;
    result.fold(
      (failure) => _emit(
        state.copyWith(
          actionInProgress: null,
          actionErrorMessage: failure.message,
        ),
      ),
      (updated) {
        ok = true;
        _emit(
          state.copyWith(
            actionInProgress: null,
            order: updated,
            successMessage: 'تم تأكيد التوزيع',
          ),
        );
      },
    );
    return ok;
  }

  /// Clears one-shot messages after the UI has consumed them.
  void consumeSuccessMessage() {
    _emit(state.copyWith(successMessage: null));
  }

  void clearActionError() {
    _emit(state.copyWith(actionErrorMessage: null));
  }

  @override
  Future<void> close() {
    stopAutoRefresh();
    return super.close();
  }
}
