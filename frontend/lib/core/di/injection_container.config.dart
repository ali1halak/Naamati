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
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i17;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_charity_usecase.dart'
    as _i408;
import '../../features/auth/domain/usecases/register_donor_usecase.dart'
    as _i1019;
import '../../features/auth/presentation/bloc/login_cubit.dart' as _i281;
import '../../features/auth/presentation/bloc/register_cubit.dart' as _i98;
import '../../features/charity/data/datasources/charity_remote_data_source.dart'
    as _i912;
import '../../features/charity/data/repositories/charity_repository_impl.dart'
    as _i227;
import '../../features/charity/domain/repositories/charity_repository.dart'
    as _i560;
import '../../features/charity/domain/usecases/accept_request_usecase.dart'
    as _i666;
import '../../features/charity/domain/usecases/confirm_distribution_usecase.dart'
    as _i1070;
import '../../features/charity/domain/usecases/confirm_pickup_usecase.dart'
    as _i1025;
import '../../features/charity/domain/usecases/get_available_requests_usecase.dart'
    as _i981;
import '../../features/charity/domain/usecases/get_my_orders_usecase.dart'
    as _i45;
import '../../features/charity/domain/usecases/get_order_audit_usecase.dart'
    as _i947;
import '../../features/charity/domain/usecases/get_order_details_usecase.dart'
    as _i1042;
import '../../features/charity/domain/usecases/get_violations_usecase.dart'
    as _i557;
import '../../features/charity/domain/usecases/record_impact_usecase.dart'
    as _i55;
import '../../features/charity/presentation/bloc/available_requests_cubit.dart'
    as _i621;
import '../../features/charity/presentation/bloc/charity_order_audit_cubit.dart'
    as _i990;
import '../../features/charity/presentation/bloc/distribution_form_cubit.dart'
    as _i360;
import '../../features/charity/presentation/bloc/my_orders_cubit.dart' as _i470;
import '../../features/charity/presentation/bloc/order_tracking_cubit.dart'
    as _i1070;
import '../../features/charity/presentation/bloc/violations_cubit.dart'
    as _i987;
import '../../features/donation/data/datasources/donation_remote_data_source.dart'
    as _i452;
import '../../features/donation/data/repositories/donation_repository_impl.dart'
    as _i493;
import '../../features/donation/domain/repositories/donation_repository.dart'
    as _i664;
import '../../features/donation/domain/usecases/cancel_donation_usecase.dart'
    as _i850;
import '../../features/donation/domain/usecases/confirm_pickup_usecase.dart'
    as _i728;
import '../../features/donation/domain/usecases/create_donation_usecase.dart'
    as _i311;
import '../../features/donation/domain/usecases/get_donation_audit_usecase.dart'
    as _i178;
import '../../features/donation/domain/usecases/get_donation_details_usecase.dart'
    as _i992;
import '../../features/donation/domain/usecases/get_food_categories_usecase.dart'
    as _i902;
import '../../features/donation/domain/usecases/get_my_donations_usecase.dart'
    as _i54;
import '../../features/donation/domain/usecases/rate_donation_usecase.dart'
    as _i543;
import '../../features/donation/domain/usecases/update_donation_usecase.dart'
    as _i754;
import '../../features/donation/presentation/bloc/create_donation_cubit.dart'
    as _i456;
import '../../features/donation/presentation/bloc/donation_audit_cubit.dart'
    as _i526;
import '../../features/donation/presentation/bloc/donation_details_cubit.dart'
    as _i477;
import '../../features/donation/presentation/bloc/my_donations_cubit.dart'
    as _i186;
import '../../features/notifications/data/datasources/notification_remote_data_source.dart'
    as _i757;
import '../../features/notifications/data/repositories/notification_repository_impl.dart'
    as _i361;
import '../../features/notifications/domain/repositories/notification_repository.dart'
    as _i367;
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart'
    as _i587;
import '../../features/notifications/domain/usecases/mark_notification_read_usecase.dart'
    as _i6;
import '../../features/notifications/presentation/bloc/notifications_cubit.dart'
    as _i66;
import '../../features/profile/data/datasources/profile_remote_data_source.dart'
    as _i847;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/usecases/change_password_usecase.dart'
    as _i550;
import '../../features/profile/domain/usecases/get_my_profile_usecase.dart'
    as _i981;
import '../../features/profile/domain/usecases/update_fcm_token_usecase.dart'
    as _i549;
import '../../features/profile/domain/usecases/update_profile_photo_usecase.dart'
    as _i669;
import '../../features/profile/domain/usecases/update_profile_usecase.dart'
    as _i478;
import '../../features/profile/presentation/bloc/profile_cubit.dart' as _i800;
import '../network/network_info.dart' as _i932;
import '../push/push_notification_service.dart' as _i992;
import '../theme/theme_cubit.dart' as _i611;
import 'injection_container.dart' as _i809;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => coreModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => coreModule.secureStorage,
    );
    gh.lazySingleton<_i361.Dio>(() => coreModule.dio);
    gh.lazySingleton<_i895.Connectivity>(() => coreModule.connectivity);
    gh.lazySingleton<_i932.NetworkInfo>(() => coreModule.networkInfo);
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => coreModule.authRemoteDataSource,
    );
    gh.lazySingleton<_i452.DonationRemoteDataSource>(
      () => coreModule.donationRemoteDataSource,
    );
    gh.lazySingleton<_i912.CharityRemoteDataSource>(
      () => coreModule.charityRemoteDataSource,
    );
    gh.lazySingleton<_i847.ProfileRemoteDataSource>(
      () => coreModule.profileRemoteDataSource,
    );
    gh.lazySingleton<_i757.NotificationRemoteDataSource>(
      () => coreModule.notificationRemoteDataSource,
    );
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => coreModule.localNotifications,
    );
    gh.lazySingleton<_i560.CharityRepository>(
      () => _i227.CharityRepositoryImpl(
        remoteDataSource: gh<_i912.CharityRemoteDataSource>(),
        networkInfo: gh<_i932.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        remoteDataSource: gh<_i107.AuthRemoteDataSource>(),
        networkInfo: gh<_i932.NetworkInfo>(),
        secureStorage: gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i334.ProfileRepositoryImpl(
        remoteDataSource: gh<_i847.ProfileRemoteDataSource>(),
        networkInfo: gh<_i932.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i611.ThemeCubit>(
      () => _i611.ThemeCubit(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i17.GetCurrentUserUseCase>(
      () => _i17.GetCurrentUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i408.RegisterCharityUseCase>(
      () => _i408.RegisterCharityUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i1019.RegisterDonorUseCase>(
      () => _i1019.RegisterDonorUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i367.NotificationRepository>(
      () => _i361.NotificationRepositoryImpl(
        remoteDataSource: gh<_i757.NotificationRemoteDataSource>(),
        networkInfo: gh<_i932.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i664.DonationRepository>(
      () => _i493.DonationRepositoryImpl(
        remoteDataSource: gh<_i452.DonationRemoteDataSource>(),
        networkInfo: gh<_i932.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i666.AcceptRequestUseCase>(
      () => _i666.AcceptRequestUseCase(gh<_i560.CharityRepository>()),
    );
    gh.lazySingleton<_i1070.ConfirmDistributionUseCase>(
      () => _i1070.ConfirmDistributionUseCase(gh<_i560.CharityRepository>()),
    );
    gh.lazySingleton<_i1025.ConfirmPickupUseCase>(
      () => _i1025.ConfirmPickupUseCase(gh<_i560.CharityRepository>()),
    );
    gh.lazySingleton<_i981.GetAvailableRequestsUseCase>(
      () => _i981.GetAvailableRequestsUseCase(gh<_i560.CharityRepository>()),
    );
    gh.lazySingleton<_i45.GetMyOrdersUseCase>(
      () => _i45.GetMyOrdersUseCase(gh<_i560.CharityRepository>()),
    );
    gh.lazySingleton<_i947.GetOrderAuditUseCase>(
      () => _i947.GetOrderAuditUseCase(gh<_i560.CharityRepository>()),
    );
    gh.lazySingleton<_i1042.GetOrderDetailsUseCase>(
      () => _i1042.GetOrderDetailsUseCase(gh<_i560.CharityRepository>()),
    );
    gh.lazySingleton<_i557.GetViolationsUseCase>(
      () => _i557.GetViolationsUseCase(gh<_i560.CharityRepository>()),
    );
    gh.lazySingleton<_i55.RecordImpactUseCase>(
      () => _i55.RecordImpactUseCase(gh<_i560.CharityRepository>()),
    );
    gh.lazySingleton<_i550.ChangePasswordUseCase>(
      () => _i550.ChangePasswordUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i981.GetMyProfileUseCase>(
      () => _i981.GetMyProfileUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i549.UpdateFcmTokenUseCase>(
      () => _i549.UpdateFcmTokenUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i669.UpdateProfilePhotoUseCase>(
      () => _i669.UpdateProfilePhotoUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.lazySingleton<_i478.UpdateProfileUseCase>(
      () => _i478.UpdateProfileUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.factory<_i360.DistributionFormCubit>(
      () => _i360.DistributionFormCubit(gh<_i55.RecordImpactUseCase>()),
    );
    gh.lazySingleton<_i587.GetNotificationsUseCase>(
      () => _i587.GetNotificationsUseCase(gh<_i367.NotificationRepository>()),
    );
    gh.lazySingleton<_i6.MarkNotificationReadUseCase>(
      () => _i6.MarkNotificationReadUseCase(gh<_i367.NotificationRepository>()),
    );
    gh.factory<_i1070.OrderTrackingCubit>(
      () => _i1070.OrderTrackingCubit(
        gh<_i1042.GetOrderDetailsUseCase>(),
        gh<_i1025.ConfirmPickupUseCase>(),
        gh<_i1070.ConfirmDistributionUseCase>(),
      ),
    );
    gh.factory<_i990.CharityOrderAuditCubit>(
      () => _i990.CharityOrderAuditCubit(gh<_i947.GetOrderAuditUseCase>()),
    );
    gh.lazySingleton<_i850.CancelDonationUseCase>(
      () => _i850.CancelDonationUseCase(gh<_i664.DonationRepository>()),
    );
    gh.lazySingleton<_i728.ConfirmPickupUseCase>(
      () => _i728.ConfirmPickupUseCase(gh<_i664.DonationRepository>()),
    );
    gh.lazySingleton<_i311.CreateDonationUseCase>(
      () => _i311.CreateDonationUseCase(gh<_i664.DonationRepository>()),
    );
    gh.lazySingleton<_i178.GetDonationAuditUseCase>(
      () => _i178.GetDonationAuditUseCase(gh<_i664.DonationRepository>()),
    );
    gh.lazySingleton<_i992.GetDonationDetailsUseCase>(
      () => _i992.GetDonationDetailsUseCase(gh<_i664.DonationRepository>()),
    );
    gh.lazySingleton<_i902.GetFoodCategoriesUseCase>(
      () => _i902.GetFoodCategoriesUseCase(gh<_i664.DonationRepository>()),
    );
    gh.lazySingleton<_i54.GetMyDonationsUseCase>(
      () => _i54.GetMyDonationsUseCase(gh<_i664.DonationRepository>()),
    );
    gh.lazySingleton<_i543.RateDonationUseCase>(
      () => _i543.RateDonationUseCase(gh<_i664.DonationRepository>()),
    );
    gh.lazySingleton<_i754.UpdateDonationUseCase>(
      () => _i754.UpdateDonationUseCase(gh<_i664.DonationRepository>()),
    );
    gh.factory<_i800.ProfileCubit>(
      () => _i800.ProfileCubit(
        gh<_i981.GetMyProfileUseCase>(),
        gh<_i478.UpdateProfileUseCase>(),
        gh<_i669.UpdateProfilePhotoUseCase>(),
        gh<_i550.ChangePasswordUseCase>(),
      ),
    );
    gh.factory<_i186.MyDonationsCubit>(
      () => _i186.MyDonationsCubit(
        gh<_i54.GetMyDonationsUseCase>(),
        gh<_i850.CancelDonationUseCase>(),
      ),
    );
    gh.lazySingleton<_i992.PushNotificationService>(
      () => _i992.PushNotificationService(
        gh<_i549.UpdateFcmTokenUseCase>(),
        gh<_i163.FlutterLocalNotificationsPlugin>(),
      ),
    );
    gh.factory<_i470.MyOrdersCubit>(
      () => _i470.MyOrdersCubit(gh<_i45.GetMyOrdersUseCase>()),
    );
    gh.factory<_i477.DonationDetailsCubit>(
      () => _i477.DonationDetailsCubit(
        gh<_i992.GetDonationDetailsUseCase>(),
        gh<_i850.CancelDonationUseCase>(),
        gh<_i728.ConfirmPickupUseCase>(),
        gh<_i543.RateDonationUseCase>(),
      ),
    );
    gh.factory<_i621.AvailableRequestsCubit>(
      () => _i621.AvailableRequestsCubit(
        gh<_i981.GetAvailableRequestsUseCase>(),
        gh<_i666.AcceptRequestUseCase>(),
      ),
    );
    gh.factory<_i987.ViolationsCubit>(
      () => _i987.ViolationsCubit(gh<_i557.GetViolationsUseCase>()),
    );
    gh.factory<_i281.LoginCubit>(
      () => _i281.LoginCubit(
        gh<_i188.LoginUseCase>(),
        gh<_i992.PushNotificationService>(),
      ),
    );
    gh.factory<_i456.CreateDonationCubit>(
      () => _i456.CreateDonationCubit(
        gh<_i902.GetFoodCategoriesUseCase>(),
        gh<_i311.CreateDonationUseCase>(),
        gh<_i754.UpdateDonationUseCase>(),
      ),
    );
    gh.factory<_i98.RegisterCubit>(
      () => _i98.RegisterCubit(
        gh<_i1019.RegisterDonorUseCase>(),
        gh<_i408.RegisterCharityUseCase>(),
        gh<_i992.PushNotificationService>(),
      ),
    );
    gh.factory<_i66.NotificationsCubit>(
      () => _i66.NotificationsCubit(
        gh<_i587.GetNotificationsUseCase>(),
        gh<_i6.MarkNotificationReadUseCase>(),
      ),
    );
    gh.factory<_i526.DonationAuditCubit>(
      () => _i526.DonationAuditCubit(
        gh<_i178.GetDonationAuditUseCase>(),
        gh<_i543.RateDonationUseCase>(),
      ),
    );
    return this;
  }
}

class _$CoreModule extends _i809.CoreModule {}
