import 'my_profile_model.dart';

/// Envelope for the profile endpoints (`GET/PUT /profile`, `POST /profile/photo`)
/// — every one of them returns the same `{ success, data: {type, profile}, message }`
/// shape, so they share this one hand-rolled model (see [MyProfileModel] for why
/// it isn't `@JsonSerializable`).
class MyProfileResponseModel {
  final bool success;
  final MyProfileModel data;
  final String? message;

  const MyProfileResponseModel({
    required this.success,
    required this.data,
    this.message,
  });

  factory MyProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return MyProfileResponseModel(
      success: json['success'] as bool,
      data: MyProfileModel.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }
}
