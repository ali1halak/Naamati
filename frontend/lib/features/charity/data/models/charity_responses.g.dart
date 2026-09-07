// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charity_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableRequestListResponseModel _$AvailableRequestListResponseModelFromJson(
  Map<String, dynamic> json,
) => AvailableRequestListResponseModel(
  success: json['success'] as bool,
  data: AvailableRequestListDataModel.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
  message: json['message'] as String?,
);

Map<String, dynamic> _$AvailableRequestListResponseModelToJson(
  AvailableRequestListResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
};

AvailableRequestListDataModel _$AvailableRequestListDataModelFromJson(
  Map<String, dynamic> json,
) => AvailableRequestListDataModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => AvailableRequestModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : DonationPaginationMetaModel.fromJson(
          json['meta'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$AvailableRequestListDataModelToJson(
  AvailableRequestListDataModel instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
