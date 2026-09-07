// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num).toInt(),
      kind: $enumDecode(
        _$NotificationKindEnumMap,
        json['type'],
        unknownValue: NotificationKind.unknown,
      ),
      payload: json['payload'] as Map<String, dynamic>,
      isRead: json['is_read'] as bool,
      donationRequestId: (json['donation_request_id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationKindEnumMap[instance.kind]!,
      'payload': instance.payload,
      'is_read': instance.isRead,
      'donation_request_id': instance.donationRequestId,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$NotificationKindEnumMap = {
  NotificationKind.requestAccepted: 'request_accepted',
  NotificationKind.handoverConfirmed: 'handover_confirmed',
  NotificationKind.requestCancelled: 'request_cancelled',
  NotificationKind.newRequestAvailable: 'new_request_available',
  NotificationKind.awaitingOtherConfirmation: 'awaiting_other_confirmation',
  NotificationKind.distributionCompleted: 'distribution_completed',
  NotificationKind.requestExpired: 'request_expired',
  NotificationKind.requestNoShow: 'request_no_show',
  NotificationKind.newRating: 'new_rating',
  NotificationKind.charityApproved: 'charity_approved',
  NotificationKind.charitySuspended: 'charity_suspended',
  NotificationKind.unknown: 'unknown',
};
