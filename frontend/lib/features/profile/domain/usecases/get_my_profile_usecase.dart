import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/my_profile.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class GetMyProfileUseCase implements UseCase<MyProfile, NoParams> {
  final ProfileRepository repository;

  GetMyProfileUseCase(this.repository);

  @override
  Future<Either<Failure, MyProfile>> call(NoParams params) {
    return repository.getMyProfile();
  }
}
