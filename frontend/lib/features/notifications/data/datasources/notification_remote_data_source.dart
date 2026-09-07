import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/notification_responses.dart';

part 'notification_remote_data_source.g.dart';

/// The signed-in account's own notification feed (`/api/v1/notifications*`)
/// — shared by donor and charity, scoped server-side to the token's owner.
@RestApi()
abstract class NotificationRemoteDataSource {
  @factoryMethod
  factory NotificationRemoteDataSource(Dio dio) = _NotificationRemoteDataSource;

  @GET('/notifications')
  Future<NotificationListResponseModel> getNotifications({
    @Query('is_read') String? isRead,
    @Query('page') int? page,
  });

  @POST('/notifications/{id}/read')
  Future<NotificationResponseModel> markRead(@Path() int id);
}
