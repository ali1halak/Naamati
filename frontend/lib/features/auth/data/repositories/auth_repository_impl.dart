import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'dart:typed_data';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.secureStorage,
  });

  User _withAuthMetadata(User user, String? accountType) {
    return User(
      id: user.id,
      name: user.name,
      type: user.type,
      email: user.email,
      phone: user.phone,
      accountType: accountType,
      status: user.status,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.login(email: email, password: password);

        if (response.success) {
          await secureStorage.write(key: StorageKeys.accessToken, value: response.data.token ?? '');
          return Right(_withAuthMetadata(response.data.user, response.data.type ?? ''));
        } else {
          return Left(ServerFailure(message: response.message ?? 'Login failed'));
        }
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> registerDonor({
    required String name,
    required String type,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.registerDonor(
          name: name,
          type: type,
          email: email,
          phone: phone,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );

        if (response.success) {
          await secureStorage.write(key: StorageKeys.accessToken, value: response.data.token ?? '');
          return Right(_withAuthMetadata(response.data.user, response.data.type ?? ''));
        } else {
          return Left(ServerFailure(message: response.message ?? 'Registration failed'));
        }
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> registerCharity({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required bool hasKitchen,
    required String address,
    required String workStart,
    required String workEnd,
    Uint8List? licenseDocumentBytes,
    String? licenseDocumentName,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        MultipartFile? licenseDocument;
        if (licenseDocumentBytes != null && licenseDocumentName != null) {
          licenseDocument = MultipartFile.fromBytes(
            licenseDocumentBytes,
            filename: licenseDocumentName,
          );
        }

        final response = await remoteDataSource.registerCharity(
          name: name,
          email: email,
          phone: phone,
          password: password,
          passwordConfirmation: passwordConfirmation,
          hasKitchen: hasKitchen,
          address: address,
          workStart: workStart,
          workEnd: workEnd,
          licenseDocument: licenseDocument,
        );

        if (response.success) {
          await secureStorage.write(key: StorageKeys.accessToken, value: response.data.token ?? '');
          return Right(_withAuthMetadata(response.data.user, response.data.type ?? ''));
        } else {
          return Left(ServerFailure(message: response.message ?? 'Registration failed'));
        }
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getCurrentUser();

        if (response.success) {
          return Right(_withAuthMetadata(response.data.user, response.data.type ?? ''));
        } else {
          return Left(ServerFailure(message: response.message ?? 'Failed to fetch user'));
        }
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return Left(const NetworkFailure());
    }
  }
}
