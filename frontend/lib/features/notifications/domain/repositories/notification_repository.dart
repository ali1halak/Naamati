import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_notification.dart';
import '../entities/paginated_notifications.dart';

/// The signed-in account's own notification feed (backend: `/api/v1/notifications*`).
abstract class NotificationRepository {
  /// `GET /notifications`. Donor and charity both call this — the backend
  /// scopes results to whichever account owns the token.
  Future<Either<Failure, PaginatedNotifications>> getNotifications({
    bool? isRead,
    int page = 1,
  });

  /// `POST /notifications/{id}/read`.
  Future<Either<Failure, AppNotification>> markRead(int id);
}
