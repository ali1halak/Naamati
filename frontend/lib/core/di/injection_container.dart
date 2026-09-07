import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/charity/data/datasources/charity_remote_data_source.dart';
import '../../features/donation/data/datasources/donation_remote_data_source.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import 'injection_container.config.dart';

final sl = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await sl.init();
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

  @lazySingleton
  DonationRemoteDataSource get donationRemoteDataSource =>
      DonationRemoteDataSource(dio);

  @lazySingleton
  CharityRemoteDataSource get charityRemoteDataSource =>
      CharityRemoteDataSource(dio);

  @lazySingleton
  ProfileRemoteDataSource get profileRemoteDataSource =>
      ProfileRemoteDataSource(dio);

  @lazySingleton
  NotificationRemoteDataSource get notificationRemoteDataSource =>
      NotificationRemoteDataSource(dio);

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @lazySingleton
  FlutterLocalNotificationsPlugin get localNotifications =>
      FlutterLocalNotificationsPlugin();
}
