import 'package:equatable/equatable.dart';

import 'app_notification.dart';

/// One page of the account's notification feed plus pagination metadata.
class PaginatedNotifications extends Equatable {
  final List<AppNotification> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedNotifications({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [items, currentPage, lastPage, total];
}
