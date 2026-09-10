import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/my_profile.dart';

/// Self-service account contracts (backend: `/api/v1/profile/*`).
abstract class ProfileRepository {
  /// `GET /profile`.
  Future<Either<Failure, MyProfile>> getMyProfile();

  /// `PUT /profile`. Only the fields relevant to the caller's own account
  /// type need to be non-null.
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
  });

  /// `POST /profile/photo` (donor avatar / charity logo).
  Future<Either<Failure, MyProfile>> updatePhoto(File photo);

  /// `POST /profile/password`.
  Future<Either<Failure, Unit>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  /// `POST /profile/fcm-token` — registers this device as the account's push
  /// target. Best-effort from the caller's point of view (see
  /// [PushNotificationService]), so failures are still surfaced as [Left]
  /// but are safe to ignore.
  Future<Either<Failure, Unit>> updateFcmToken(String fcmToken);
}
