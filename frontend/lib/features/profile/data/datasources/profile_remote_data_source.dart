import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/profile_responses.dart';

part 'profile_remote_data_source.g.dart';

/// Self-service account endpoints (`/api/v1/profile/*`), shared by donors
/// and charities — the backend resolves which one from the auth token.
@RestApi()
abstract class ProfileRemoteDataSource {
  @factoryMethod
  factory ProfileRemoteDataSource(Dio dio) = _ProfileRemoteDataSource;

  @GET('/profile')
  Future<MyProfileResponseModel> getMyProfile();

  /// Field set differs by account type — the caller only ever fills in the
  /// fields relevant to its own role; the rest stay null and are omitted.
  @PUT('/profile')
  Future<MyProfileResponseModel> updateProfile({
    @Field('name') required String name,
    @Field('phone') required String phone,
    @Field('type') String? type,
    @Field('address') String? address,
    @Field('latitude') double? latitude,
    @Field('longitude') double? longitude,
    @Field('work_start') String? workStart,
    @Field('work_end') String? workEnd,
    @Field('has_kitchen') bool? hasKitchen,
  });

  @MultiPart()
  @POST('/profile/photo')
  Future<MyProfileResponseModel> updatePhoto({
    @Part(name: 'photo') required File photo,
  });

  @POST('/profile/password')
  Future<void> changePassword({
    @Field('current_password') required String currentPassword,
    @Field('password') required String password,
    @Field('password_confirmation') required String passwordConfirmation,
  });

  @POST('/profile/fcm-token')
  Future<void> updateFcmToken({@Field('fcm_token') required String fcmToken});
}
