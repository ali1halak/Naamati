// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationListResponseModel _$NotificationListResponseModelFromJson(
  Map<String, dynamic> json,
) => NotificationListResponseModel(
  success: json['success'] as bool,
  data: NotificationListDataModel.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String?,
);

Map<String, dynamic> _$NotificationListResponseModelToJson(
  NotificationListResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
};

NotificationListDataModel _$NotificationListDataModelFromJson(
  Map<String, dynamic> json,
) => NotificationListDataModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : NotificationPaginationMetaModel.fromJson(
          json['meta'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$NotificationListDataModelToJson(
  NotificationListDataModel instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

NotificationPaginationMetaModel _$NotificationPaginationMetaModelFromJson(
  Map<String, dynamic> json,
) => NotificationPaginationMetaModel(
  currentPage: (json['current_page'] as num?)?.toInt(),
  lastPage: (json['last_page'] as num?)?.toInt(),
  perPage: (json['per_page'] as num?)?.toInt(),
  total: (json['total'] as num?)?.toInt(),
);

Map<String, dynamic> _$NotificationPaginationMetaModelToJson(
  NotificationPaginationMetaModel instance,
) => <String, dynamic>{
  'current_page': instance.currentPage,
  'last_page': instance.lastPage,
  'per_page': instance.perPage,
  'total': instance.total,
};

NotificationResponseModel _$NotificationResponseModelFromJson(
  Map<String, dynamic> json,
) => NotificationResponseModel(
  success: json['success'] as bool,
  data: NotificationModel.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$NotificationResponseModelToJson(
  NotificationResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
};
