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

  @POST('/register/charity')
  Future<AuthResponseModel> registerCharity({
    @Field('name') required String name,
    @Field('email') required String email,
    @Field('phone') required String phone,
    @Field('password') required String password,
    @Field('password_confirmation') required String passwordConfirmation,
    @Field('has_kitchen') required bool hasKitchen,
    @Field('address') required String address,
    @Field('work_start') required String workStart,
    @Field('work_end') required String workEnd,
  });

  @GET(ApiConstants.pathMe)
  Future<MeResponseModel> getCurrentUser();
}
