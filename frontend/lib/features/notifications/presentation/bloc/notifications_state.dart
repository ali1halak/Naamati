import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/app_notification.dart';

class NotificationsState extends Equatable {
  final BlocStatus status;
  final String? errorMessage;
  final List<AppNotification> notifications;

  /// 1-based page the current [notifications] end at.
  final int currentPage;

  /// Total pages the backend reports.
  final int lastPage;

  /// Whether the next page is currently being fetched (infinite scroll).
  final bool isLoadingMore;

  const NotificationsState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.notifications = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingMore = false,
  });

  bool get isLoading => status == BlocStatus.loading;
  bool get isFailure => status == BlocStatus.failure;
  bool get isSuccess => status == BlocStatus.success;
  bool get isEmpty => isSuccess && notifications.isEmpty;
  bool get hasMore => currentPage < lastPage;

  static const Object _unset = Object();

  NotificationsState copyWith({
    BlocStatus? status,
    Object? errorMessage = _unset,
    List<AppNotification>? notifications,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      notifications: notifications ?? this.notifications,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    notifications,
    currentPage,
    lastPage,
    isLoadingMore,
  ];
}
