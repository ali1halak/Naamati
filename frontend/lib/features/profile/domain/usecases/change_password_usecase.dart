import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class ChangePasswordUseCase implements UseCase<Unit, ChangePasswordParams> {
  final ProfileRepository repository;

  ChangePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ChangePasswordParams params) {
    return repository.changePassword(
      currentPassword: params.currentPassword,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
  }
}

class ChangePasswordParams extends Equatable {
  final String currentPassword;
  final String password;
  final String passwordConfirmation;

  const ChangePasswordParams({
    required this.currentPassword,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [currentPassword, password, passwordConfirmation];
}
