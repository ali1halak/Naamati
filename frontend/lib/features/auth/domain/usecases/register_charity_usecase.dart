import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterCharityUseCase implements UseCase<User, RegisterCharityParams> {
  final AuthRepository repository;

  RegisterCharityUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterCharityParams params) async {
    return repository.registerCharity(
      name: params.name,
      email: params.email,
      phone: params.phone,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
      hasKitchen: params.hasKitchen,
      address: params.address,
      workStart: params.workStart,
      workEnd: params.workEnd,
    );
  }
}

class RegisterCharityParams extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;
  final bool hasKitchen;
  final String address;
  final String workStart;
  final String workEnd;

  const RegisterCharityParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    required this.hasKitchen,
    required this.address,
    required this.workStart,
    required this.workEnd,
  });

  @override
  List<Object> get props => [
    name,
    email,
    phone,
    password,
    passwordConfirmation,
    hasKitchen,
    address,
    workStart,
    workEnd,
  ];
}
