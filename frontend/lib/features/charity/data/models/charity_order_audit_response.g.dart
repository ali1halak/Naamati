// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charity_order_audit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharityOrderAuditResponseModel _$CharityOrderAuditResponseModelFromJson(
  Map<String, dynamic> json,
) => CharityOrderAuditResponseModel(
  success: json['success'] as bool,
  data: CharityOrderAuditModel.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$CharityOrderAuditResponseModelToJson(
  CharityOrderAuditResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
};
