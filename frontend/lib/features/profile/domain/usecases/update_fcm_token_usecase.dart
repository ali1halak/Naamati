import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class UpdateFcmTokenUseCase implements UseCase<Unit, UpdateFcmTokenParams> {
  final ProfileRepository repository;

  UpdateFcmTokenUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateFcmTokenParams params) {
    return repository.updateFcmToken(params.fcmToken);
  }
}

class UpdateFcmTokenParams extends Equatable {
  final String fcmToken;

  const UpdateFcmTokenParams(this.fcmToken);

  @override
  List<Object?> get props => [fcmToken];
}
