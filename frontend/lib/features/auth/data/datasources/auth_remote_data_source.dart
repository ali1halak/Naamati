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

  @GET(ApiConstants.pathMe)
  Future<MeResponseModel> getCurrentUser();
}
