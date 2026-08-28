// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeResponseModel _$MeResponseModelFromJson(Map<String, dynamic> json) =>
    MeResponseModel(
      success: json['success'] as bool,
      data: MeDataModel.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$MeResponseModelToJson(MeResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'message': instance.message,
    };

MeDataModel _$MeDataModelFromJson(Map<String, dynamic> json) => MeDataModel(
  type: json['type'] as String,
  user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MeDataModelToJson(MeDataModel instance) =>
    <String, dynamic>{'type': instance.type, 'user': instance.user};
