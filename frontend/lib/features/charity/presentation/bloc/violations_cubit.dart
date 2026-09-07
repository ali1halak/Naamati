import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/usecases/get_violations_usecase.dart';
import 'violations_state.dart';

@injectable
class ViolationsCubit extends Cubit<ViolationsState> {
  final GetViolationsUseCase _getViolationsUseCase;

  ViolationsCubit(this._getViolationsUseCase) : super(const ViolationsState());

  /// Loads (or reloads) the first page — used on open and pull-to-refresh.
  Future<void> loadViolations() async {
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        errorMessage: null,
        currentPage: 1,
        lastPage: 1,
        isLoadingMore: false,
      ),
    );

    final result = await _getViolationsUseCase(const GetViolationsParams());

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
            violations: page.items,
            compliance: page.compliance,
            currentPage: page.currentPage,
            lastPage: page.lastPage,
          ),
        );
      },
    );
  }

  /// Fetches the next page and appends it. No-op while already loading or
  /// once the backend reports no further pages.
  Future<void> loadMore() async {
    final state = this.state;
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true, errorMessage: null));

    final result = await _getViolationsUseCase(
      GetViolationsParams(page: state.currentPage + 1),
    );

    result.fold(
      (failure) {
        if (isClosed) return;
        emit(
          state.copyWith(isLoadingMore: false, errorMessage: failure.message),
        );
      },
      (page) {
        final existing = state.violations;
        final fresh = page.items
            .where((item) => !existing.any((e) => e.id == item.id))
            .toList();
        if (isClosed) return;
        emit(
          state.copyWith(
            status: BlocStatus.success,
            isLoadingMore: false,
            violations: [...existing, ...fresh],
            currentPage: page.currentPage,
            lastPage: page.lastPage,
          ),
        );
      },
    );
  }
}
