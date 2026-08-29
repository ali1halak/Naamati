// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i17;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/register_charity_usecase.dart'
    as _i408;
import '../../features/auth/domain/usecases/register_donor_usecase.dart'
    as _i1019;
import '../../features/auth/presentation/bloc/login_cubit.dart' as _i281;
import '../../features/auth/presentation/bloc/register_cubit.dart' as _i98;
import '../network/network_info.dart' as _i932;
import 'injection_container.dart' as _i809;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => coreModule.secureStorage,
    );
    gh.lazySingleton<_i361.Dio>(() => coreModule.dio);
    gh.lazySingleton<_i895.Connectivity>(() => coreModule.connectivity);
    gh.lazySingleton<_i932.NetworkInfo>(() => coreModule.networkInfo);
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => coreModule.authRemoteDataSource,
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        remoteDataSource: gh<_i107.AuthRemoteDataSource>(),
        networkInfo: gh<_i932.NetworkInfo>(),
        secureStorage: gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i17.GetCurrentUserUseCase>(
      () => _i17.GetCurrentUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i408.RegisterCharityUseCase>(
      () => _i408.RegisterCharityUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i1019.RegisterDonorUseCase>(
      () => _i1019.RegisterDonorUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i98.RegisterCubit>(
      () => _i98.RegisterCubit(
        gh<_i1019.RegisterDonorUseCase>(),
        gh<_i408.RegisterCharityUseCase>(),
      ),
    );
    gh.factory<_i281.LoginCubit>(
      () => _i281.LoginCubit(gh<_i188.LoginUseCase>()),
    );
    return this;
  }
}

class _$CoreModule extends _i809.CoreModule {}
