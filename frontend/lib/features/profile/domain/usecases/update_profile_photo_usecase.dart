import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/my_profile.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class UpdateProfilePhotoUseCase
    implements UseCase<MyProfile, UpdateProfilePhotoParams> {
  final ProfileRepository repository;

  UpdateProfilePhotoUseCase(this.repository);

  @override
  Future<Either<Failure, MyProfile>> call(UpdateProfilePhotoParams params) {
    return repository.updatePhoto(params.photo);
  }
}

class UpdateProfilePhotoParams extends Equatable {
  final File photo;

  const UpdateProfilePhotoParams({required this.photo});

  @override
  List<Object?> get props => [photo];
}
