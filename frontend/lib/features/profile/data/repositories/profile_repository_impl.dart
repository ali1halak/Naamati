import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/my_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, MyProfile>> getMyProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getMyProfile();
        if (response.success) {
          return Right(response.data);
        }
        return Left(
          ServerFailure(message: response.message ?? 'فشل تحميل الملف الشخصي'),
        );
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, MyProfile>> updateProfile({
    required String name,
    required String phone,
    String? type,
    String? address,
    double? latitude,
    double? longitude,
    String? workStart,
    String? workEnd,
    bool? hasKitchen,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.updateProfile(
          name: name,
          phone: phone,
          type: type,
          address: address,
          latitude: latitude,
          longitude: longitude,
          workStart: workStart,
          workEnd: workEnd,
          hasKitchen: hasKitchen,
        );
        if (response.success) {
          return Right(response.data);
        }
        return Left(
          ServerFailure(message: response.message ?? 'فشل تحديث الملف الشخصي'),
        );
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, MyProfile>> updatePhoto(File photo) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.updatePhoto(photo: photo);
        if (response.success) {
          return Right(response.data);
        }
        return Left(
          ServerFailure(message: response.message ?? 'فشل تحديث الصورة'),
        );
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.changePassword(
          currentPassword: currentPassword,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
        return const Right(unit);
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateFcmToken(String fcmToken) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateFcmToken(fcmToken: fcmToken);
        return const Right(unit);
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
