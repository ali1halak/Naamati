import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';
import '../models/me_response_model.dart';

part 'auth_remote_data_source.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  @factoryMethod
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  @POST(ApiConstants.pathLogin)
  Future<AuthResponseModel> login({
    @Field('email') required String email,
    @Field('password') required String password,
  });

  @POST('/register/donor')
  Future<AuthResponseModel> registerDonor({
    @Field('name') required String name,
    @Field('type') required String type,
    @Field('email') required String email,
    @Field('phone') required String phone,
    @Field('password') required String password,
    @Field('password_confirmation') required String passwordConfirmation,
  });

  @MultiPart()
  @POST('/register/charity')
  Future<AuthResponseModel> registerCharity({
    @Part(name: 'name') required String name,
    @Part(name: 'email') required String email,
    @Part(name: 'phone') required String phone,
    @Part(name: 'password') required String password,
    @Part(name: 'password_confirmation') required String passwordConfirmation,
    @Part(name: 'has_kitchen') required bool hasKitchen,
    @Part(name: 'address') required String address,
    @Part(name: 'work_start') required String workStart,
    @Part(name: 'work_end') required String workEnd,
    @Part(name: 'license_document') MultipartFile? licenseDocument,
  });

  @GET(ApiConstants.pathMe)
  Future<MeResponseModel> getCurrentUser();
}
