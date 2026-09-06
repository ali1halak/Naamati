import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/my_donations_filter.dart';
import '../../domain/usecases/cancel_donation_usecase.dart';
import '../../domain/usecases/get_my_donations_usecase.dart';
import 'my_donations_state.dart';

@injectable
class MyDonationsCubit extends Cubit<MyDonationsState> {
  final GetMyDonationsUseCase _getMyDonationsUseCase;
  final CancelDonationUseCase _cancelDonationUseCase;

  MyDonationsCubit(this._getMyDonationsUseCase, this._cancelDonationUseCase)
    : super(const MyDonationsState());

  /// Loads (or reloads) the first page of the donor's donations with [filter].
  ///
  /// Passing null keeps the currently applied filter (e.g. pull-to-refresh),
  /// so an explicit change must always pass a concrete [MyDonationsFilter].
  Future<void> loadDonations({MyDonationsFilter? filter}) async {
    final effectiveFilter = filter ?? state.filter;
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        filter: effectiveFilter,
        errorMessage: null,
        // A new fetch always starts the pagination over.
        currentPage: 1,
        lastPage: 1,
        isLoadingMore: false,
      ),
    );

    final result = await _getMyDonationsUseCase(
      GetMyDonationsParams(filter: effectiveFilter),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: BlocStatus.success,
          donations: page.items,
          currentPage: page.currentPage,
          lastPage: page.lastPage,
        ),
      ),
    );
  }

  /// Fetches the next page of the current filter and appends it.
  ///
  /// No-op while a page is already loading, while the first page is still
  /// loading, or when the backend reports no further pages.
  Future<void> loadMore() async {
    final state = this.state;
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true, errorMessage: null));

    final result = await _getMyDonationsUseCase(
      GetMyDonationsParams(filter: state.filter, page: state.currentPage + 1),
    );

    result.fold(
      // Keep the already-loaded list on screen; surface the error via
      // [errorMessage] without knocking the user back to the error screen.
      (failure) => emit(
        state.copyWith(isLoadingMore: false, errorMessage: failure.message),
      ),
      (page) {
        final existing = state.donations;
        final fresh = page.items
            .where((item) => !existing.any((e) => e.id == item.id))
            .toList();
        emit(
          state.copyWith(
            status: BlocStatus.success,
            isLoadingMore: false,
            donations: [...existing, ...fresh],
            currentPage: page.currentPage,
            lastPage: page.lastPage,
          ),
        );
      },
    );
  }

  /// Cancels the donation with [id] (donor's own voluntary cancel) and
  /// refreshes the list so the card flips to its new terminal state.
  ///
  /// Returns true on success; on failure [errorMessage] carries the reason
  /// and the list is left untouched.
  Future<bool> cancelDonation(int id, {String? reason}) async {
    emit(state.copyWith(cancellingId: id, errorMessage: null));

    final result = await _cancelDonationUseCase(
      CancelDonationParams(id: id, reason: reason),
    );

    bool ok = false;
    result.fold(
      (failure) => emit(
        state.copyWith(cancellingId: null, errorMessage: failure.message),
      ),
      (_) => ok = true,
    );

    if (ok) {
      // Re-fetch with the same filter so pagination metadata stays honest.
      await loadDonations();
    }
    return ok;
  }
}
