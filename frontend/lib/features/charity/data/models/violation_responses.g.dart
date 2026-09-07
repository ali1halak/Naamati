// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'violation_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViolationListResponseModel _$ViolationListResponseModelFromJson(
  Map<String, dynamic> json,
) => ViolationListResponseModel(
  success: json['success'] as bool,
  data: ViolationListDataModel.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$ViolationListResponseModelToJson(
  ViolationListResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
};

ViolationListDataModel _$ViolationListDataModelFromJson(
  Map<String, dynamic> json,
) => ViolationListDataModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => ViolationModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : ViolationPaginationMetaModel.fromJson(
          json['meta'] as Map<String, dynamic>,
        ),
  compliance: json['compliance'] == null
      ? null
      : ComplianceInfoModel.fromJson(
          json['compliance'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ViolationListDataModelToJson(
  ViolationListDataModel instance,
) => <String, dynamic>{
  'data': instance.data,
  'meta': instance.meta,
  'compliance': instance.compliance,
};

ViolationPaginationMetaModel _$ViolationPaginationMetaModelFromJson(
  Map<String, dynamic> json,
) => ViolationPaginationMetaModel(
  currentPage: (json['current_page'] as num?)?.toInt(),
  lastPage: (json['last_page'] as num?)?.toInt(),
  perPage: (json['per_page'] as num?)?.toInt(),
  total: (json['total'] as num?)?.toInt(),
);

Map<String, dynamic> _$ViolationPaginationMetaModelToJson(
  ViolationPaginationMetaModel instance,
) => <String, dynamic>{
  'current_page': instance.currentPage,
  'last_page': instance.lastPage,
  'per_page': instance.perPage,
  'total': instance.total,
};
