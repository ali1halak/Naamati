import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> registerDonor({
    required String name,
    required String type,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, User>> registerCharity({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required bool hasKitchen,
    required String address,
    required double latitude,
    required double longitude,
    required String workStart,
    required String workEnd,
    Uint8List? licenseDocumentBytes,
    String? licenseDocumentName,
  });

  Future<Either<Failure, User>> getCurrentUser();

  /// Best-effort server-side token revocation, then always clears the local
  /// session — the token may already be stale, but the user must be able to
  /// log out regardless of network state.
  Future<void> logout();
}
