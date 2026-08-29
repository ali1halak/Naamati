import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/domain/usecases/register_donor_usecase.dart';
import '../../features/auth/domain/usecases/register_charity_usecase.dart';
import '../../features/auth/presentation/bloc/register_cubit.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import 'injection_container.config.dart';

final sl = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() {
  sl.init();

  // Manual registrations for registration flow (codegen may not have run yet).
  // These mirror the generated registrations so `sl<RegisterCubit>()` works
  // immediately from UI code.
  sl.registerLazySingleton<RegisterDonorUseCase>(
    () => RegisterDonorUseCase(sl()),
  );

  sl.registerLazySingleton<RegisterCharityUseCase>(
    () => RegisterCharityUseCase(sl()),
  );

  sl.registerFactory<RegisterCubit>(
    () => RegisterCubit(sl<RegisterDonorUseCase>(), sl<RegisterCharityUseCase>()),
  );
}

@module
abstract class CoreModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  Dio get dio => DioClient.create(sl<FlutterSecureStorage>());

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  NetworkInfo get networkInfo => NetworkInfoImpl(connectivity);

  @lazySingleton
  AuthRemoteDataSource get authRemoteDataSource => AuthRemoteDataSource(dio);
}
