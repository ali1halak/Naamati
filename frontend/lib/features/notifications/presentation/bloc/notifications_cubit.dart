import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notifications_state.dart';

@injectable
class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;

  NotificationsCubit(
    this._getNotificationsUseCase,
    this._markNotificationReadUseCase,
  ) : super(const NotificationsState());

  /// Loads (or reloads) the first page — used on open and pull-to-refresh.
  Future<void> load() async {
    emit(
      state.copyWith(
        status: BlocStatus.loading,
        errorMessage: null,
        currentPage: 1,
        lastPage: 1,
        isLoadingMore: false,
      ),
    );

    final result = await _getNotificationsUseCase(
      const GetNotificationsParams(),
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
            notifications: page.items,
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

    final result = await _getNotificationsUseCase(
      GetNotificationsParams(page: state.currentPage + 1),
    );

    result.fold(
      (failure) {
        if (isClosed) return;
        emit(
          state.copyWith(isLoadingMore: false, errorMessage: failure.message),
        );
      },
      (page) {
        final existing = state.notifications;
        final fresh = page.items
            .where((item) => !existing.any((e) => e.id == item.id))
            .toList();
        if (isClosed) return;
        emit(
          state.copyWith(
            status: BlocStatus.success,
            isLoadingMore: false,
            notifications: [...existing, ...fresh],
            currentPage: page.currentPage,
            lastPage: page.lastPage,
          ),
        );
      },
    );
  }

  /// Marks [id] as read in place — no need to re-fetch the whole page for a
  /// single flag flip.
  Future<void> markRead(int id) async {
    final index = state.notifications.indexWhere((n) => n.id == id);
    if (index == -1 || state.notifications[index].isRead) return;

    final result = await _markNotificationReadUseCase(
      MarkNotificationReadParams(id),
    );

    result.fold((_) {}, (updated) {
      if (isClosed) return;
      emit(
        state.copyWith(
          notifications: [
            for (final n in state.notifications)
              if (n.id == id) updated else n,
          ],
        ),
      );
    });
  }
}
