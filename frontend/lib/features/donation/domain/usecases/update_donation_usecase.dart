import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/donation_request.dart';
import '../params/create_donation_params.dart';
import '../repositories/donation_repository.dart';

@lazySingleton
class UpdateDonationUseCase
    implements UseCase<DonationRequest, UpdateDonationParams> {
  final DonationRepository repository;

  UpdateDonationUseCase(this.repository);

  @override
  Future<Either<Failure, DonationRequest>> call(UpdateDonationParams params) {
    return repository.updateDonation(params.id, params.data);
  }
}

class UpdateDonationParams extends Equatable {
  final int id;
  final CreateDonationParams data;

  const UpdateDonationParams({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}
