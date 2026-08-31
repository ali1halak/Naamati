import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/usecases/cancel_donation_usecase.dart';
import '../../domain/usecases/confirm_pickup_usecase.dart';
import '../../domain/usecases/get_donation_details_usecase.dart';
import '../../domain/usecases/rate_donation_usecase.dart';
import 'donation_details_state.dart';

/// Cubit behind the donation tracking screen (Screens 3 & 4 of the donor flow).
///
/// Besides mutations (cancel / confirm pickup / rate) it keeps the donation
/// fresh while the screen is open: [startAutoRefresh] polls every 15s while
/// the donation is still active, so `pending → accepted` reflects on screen
/// without manual pull-to-refresh.
@injectable
class DonationDetailsCubit extends Cubit<DonationDetailsState> {
  final GetDonationDetailsUseCase _getDonationDetailsUseCase;
  final CancelDonationUseCase _cancelDonationUseCase;
  final ConfirmPickupUseCase _confirmPickupUseCase;
  final RateDonationUseCase _rateDonationUseCase;

  DonationDetailsCubit(
    this._getDonationDetailsUseCase,
    this._cancelDonationUseCase,
    this._confirmPickupUseCase,
    this._rateDonationUseCase,
  ) : super(const DonationDetailsState());

  static const Duration pollInterval = Duration(seconds: 15);
  Timer? _pollTimer;
  bool _refreshing = false;

  /// Full load — shows the page-level loading state.
  Future<void> load(int id) async {
    emit(state.copyWith(status: BlocStatus.loading, errorMessage: null));

    final result = await _getDonationDetailsUseCase(GetDonationDetailsParams(id: id));

    result.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, errorMessage: failure.message)),
      (donation) => emit(state.copyWith(status: BlocStatus.success, donation: donation)),
    );
  }

  /// Silent refresh — keeps the current donation on screen while updating.
  Future<void> refresh() async {
    final donation = state.donation;
    if (donation == null || _refreshing) return;
    _refreshing = true;
    try {
      final result = await _getDonationDetailsUseCase(GetDonationDetailsParams(id: donation.id));
      result.fold(
        // Silent failures keep the last known donation (e.g. flaky network).
        (_) {},
        (updated) => emit(state.copyWith(donation: updated)),
      );
    } finally {
      _refreshing = false;
    }
  }

  void startAutoRefresh() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(pollInterval, (_) {
      final donation = state.donation;
      if (donation != null && donation.status.isActive && !_refreshing) {
        refresh();
      }
    });
  }

  void stopAutoRefresh() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ── Mutations ───────────────────────────────────────────────────────────────

  Future<void> cancelDonation({String? reason}) async {
    final donation = state.donation;
    if (donation == null) return;

    emit(state.copyWith(actionInProgress: DonationAction.cancel, actionErrorMessage: null));
    final result = await _cancelDonationUseCase(
      CancelDonationParams(id: donation.id, reason: reason),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(actionInProgress: null, actionErrorMessage: failure.message),
      ),
      (updated) => emit(
        state.copyWith(
          actionInProgress: null,
          donation: updated,
          successMessage: 'تم إلغاء الطلب',
        ),
      ),
    );
  }

  Future<void> confirmPickup({required String qrToken}) async {
    final donation = state.donation;
    if (donation == null) return;

    emit(state.copyWith(actionInProgress: DonationAction.confirmPickup, actionErrorMessage: null));
    final result = await _confirmPickupUseCase(
      ConfirmPickupParams(id: donation.id, qrToken: qrToken.trim()),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(actionInProgress: null, actionErrorMessage: failure.message),
      ),
      (updated) => emit(
        state.copyWith(
          actionInProgress: null,
          donation: updated,
          successMessage: 'تم تأكيد التسليم بنجاح',
        ),
      ),
    );
  }

  Future<void> rateDonation({required int stars, String? comment}) async {
    final donation = state.donation;
    if (donation == null) return;

    emit(state.copyWith(actionInProgress: DonationAction.rate, actionErrorMessage: null));
    final result = await _rateDonationUseCase(
      RateDonationParams(id: donation.id, stars: stars, comment: comment),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(actionInProgress: null, actionErrorMessage: failure.message),
      ),
      (_) async {
        emit(
          state.copyWith(
            actionInProgress: null,
            successMessage: 'شكراً لتقييمك',
          ),
        );
        // Pull the freshly-rated donation so `rating` is embedded.
        await refresh();
      },
    );
  }

  /// Clears one-shot messages after the UI has consumed them.
  void consumeSuccessMessage() {
    emit(state.copyWith(successMessage: null));
  }

  void clearActionError() {
    emit(state.copyWith(actionErrorMessage: null));
  }

  @override
  Future<void> close() {
    stopAutoRefresh();
    return super.close();
  }
}
