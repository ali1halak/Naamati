import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final bool success;
  final AuthDataModel data;
  final String? message;

  const AuthResponseModel({required this.success, required this.data, this.message});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}

@JsonSerializable()
class AuthDataModel {
  final String? type;
  final UserModel user;
  final String? token;

  const AuthDataModel({this.type, required this.user, this.token});

  factory AuthDataModel.fromJson(Map<String, dynamic> json) => _$AuthDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthDataModelToJson(this);
}
