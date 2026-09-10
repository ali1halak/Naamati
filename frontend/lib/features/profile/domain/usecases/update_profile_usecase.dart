import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/my_profile.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class UpdateProfileUseCase implements UseCase<MyProfile, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, MyProfile>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      name: params.name,
      phone: params.phone,
      type: params.type,
      address: params.address,
      latitude: params.latitude,
      longitude: params.longitude,
      workStart: params.workStart,
      workEnd: params.workEnd,
      hasKitchen: params.hasKitchen,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String name;
  final String phone;
  final String? type;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? workStart;
  final String? workEnd;
  final bool? hasKitchen;

  const UpdateProfileParams({
    required this.name,
    required this.phone,
    this.type,
    this.address,
    this.latitude,
    this.longitude,
    this.workStart,
    this.workEnd,
    this.hasKitchen,
  });

  @override
  List<Object?> get props => [
    name,
    phone,
    type,
    address,
    latitude,
    longitude,
    workStart,
    workEnd,
    hasKitchen,
  ];
}
