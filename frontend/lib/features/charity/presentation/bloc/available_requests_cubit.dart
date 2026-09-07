import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../../donation/domain/entities/donation_request.dart';
import '../../domain/usecases/accept_request_usecase.dart';
import '../../domain/usecases/get_available_requests_usecase.dart';
import 'available_requests_state.dart';

@injectable
class AvailableRequestsCubit extends Cubit<AvailableRequestsState> {
  final GetAvailableRequestsUseCase _getAvailableRequestsUseCase;
  final AcceptRequestUseCase _acceptRequestUseCase;

  AvailableRequestsCubit(
    this._getAvailableRequestsUseCase,
    this._acceptRequestUseCase,
  ) : super(const AvailableRequestsState());

  /// Loads (or reloads) the first page of open requests.
  Future<void> loadRequests() async {
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        errorMessage: null,
        currentPage: 1,
        lastPage: 1,
        isLoadingMore: false,
      ),
    );

    final result = await _getAvailableRequestsUseCase(
      const GetAvailableRequestsParams(),
    );

    result.fold(
      (failure) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: BlocStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (page) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: BlocStatus.success,
            requests: page.items,
            currentPage: page.currentPage,
            lastPage: page.lastPage,
          ),
        );
      },
    );
  }

  /// Fetches the next page and appends it.
  Future<void> loadMore() async {
    final state = this.state;
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true, errorMessage: null));

    final result = await _getAvailableRequestsUseCase(
      GetAvailableRequestsParams(page: state.currentPage + 1),
    );

    result.fold(
      (failure) {
        if (isClosed) return;
        emit(
          state.copyWith(isLoadingMore: false, errorMessage: failure.message),
        );
      },
      (page) {
        final existing = state.requests;
        final fresh = page.items
            .where((item) => !existing.any((e) => e.id == item.id))
            .toList();
        if (isClosed) return;
        emit(
          state.copyWith(
            status: BlocStatus.success,
            isLoadingMore: false,
            requests: [...existing, ...fresh],
            currentPage: page.currentPage,
            lastPage: page.lastPage,
          ),
        );
      },
    );
  }

  /// Claims request [id] with the given [etaMinutes]. On success the card is
  /// dropped from the list (it is no longer available) and the freshly
  /// accepted [DonationRequest] is returned so the caller can navigate to
  /// its tracking screen; returns null on failure, leaving [acceptErrorMessage]
  /// set.
  Future<DonationRequest?> acceptRequest(
    int id, {
    required int etaMinutes,
  }) async {
    emit(state.copyWith(acceptingId: id, acceptErrorMessage: null));

    final result = await _acceptRequestUseCase(
      AcceptRequestParams(id: id, etaMinutes: etaMinutes),
    );

    DonationRequest? accepted;
    result.fold(
      (failure) {
        if (isClosed) return;
        emit(
          state.copyWith(
            acceptingId: null,
            acceptErrorMessage: failure.message,
          ),
        );
      },
      (donation) {
        accepted = donation;
        if (isClosed) return;
        emit(
          state.copyWith(
            acceptingId: null,
            requests: state.requests.where((r) => r.id != id).toList(),
          ),
        );
      },
    );
    return accepted;
  }
}
