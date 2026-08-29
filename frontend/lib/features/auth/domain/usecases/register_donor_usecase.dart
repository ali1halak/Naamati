import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterDonorUseCase implements UseCase<User, RegisterDonorParams> {
  final AuthRepository repository;

  RegisterDonorUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterDonorParams params) async {
    return repository.registerDonor(
      name: params.name,
      type: params.type,
      email: params.email,
      phone: params.phone,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }
}

class RegisterDonorParams extends Equatable {
  final String name;
  final String type;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;

  const RegisterDonorParams({
    required this.name,
    required this.type,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props => [name, type, email, phone, password, passwordConfirmation];
}
