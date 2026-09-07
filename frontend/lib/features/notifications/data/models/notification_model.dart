import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/app_notification.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    @JsonKey(name: 'type', unknownEnumValue: NotificationKind.unknown)
    required super.kind,
    required super.payload,
    @JsonKey(name: 'is_read') required super.isRead,
    @JsonKey(name: 'donation_request_id') super.donationRequestId,
    @JsonKey(name: 'created_at') super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
