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
    required String workStart,
    required String workEnd,
  });

  Future<Either<Failure, User>> getCurrentUser();
}
