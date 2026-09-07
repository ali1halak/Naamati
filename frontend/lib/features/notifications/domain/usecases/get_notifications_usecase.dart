import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_notifications.dart';
import '../repositories/notification_repository.dart';

@lazySingleton
class GetNotificationsUseCase
    implements UseCase<PaginatedNotifications, GetNotificationsParams> {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedNotifications>> call(
    GetNotificationsParams params,
  ) {
    return repository.getNotifications(
      isRead: params.isRead,
      page: params.page,
    );
  }
}

class GetNotificationsParams extends Equatable {
  final bool? isRead;

  /// 1-based page to fetch.
  final int page;

  const GetNotificationsParams({this.isRead, this.page = 1});

  @override
  List<Object?> get props => [isRead, page];
}
