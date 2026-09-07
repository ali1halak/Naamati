import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/paginated_notifications.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedNotifications>> getNotifications({
    bool? isRead,
    int page = 1,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getNotifications(
          isRead: isRead == null ? null : (isRead ? 'true' : 'false'),
          page: page,
        );
        if (response.success) {
          final payload = response.data;
          final meta = payload.meta;
          return Right(
            PaginatedNotifications(
              items: payload.data,
              currentPage: meta?.currentPage ?? page,
              lastPage: meta?.lastPage ?? page,
              total: meta?.total ?? payload.data.length,
            ),
          );
        }
        return Left(
          ServerFailure(message: response.message ?? 'فشل تحميل الإشعارات'),
        );
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AppNotification>> markRead(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.markRead(id);
        if (response.success) {
          return Right(response.data);
        }
        return Left(
          ServerFailure(
            message: response.message ?? 'فشل تعليم الإشعار كمقروء',
          ),
        );
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
