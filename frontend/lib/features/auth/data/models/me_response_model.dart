import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'me_response_model.g.dart';

@JsonSerializable()
class MeResponseModel {
  final bool success;
  final MeDataModel data;
  final String? message;

  const MeResponseModel({
    required this.success,
    required this.data,
    this.message,
  });

  factory MeResponseModel.fromJson(Map<String, dynamic> json) =>
      _$MeResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$MeResponseModelToJson(this);
}

@JsonSerializable()
class MeDataModel {
  final String? type;
  final UserModel user;

  const MeDataModel({this.type, required this.user});

  factory MeDataModel.fromJson(Map<String, dynamic> json) =>
      _$MeDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$MeDataModelToJson(this);
}
