import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/donation_request.dart';
import '../params/create_donation_params.dart';
import '../repositories/donation_repository.dart';

@lazySingleton
class CreateDonationUseCase implements UseCase<DonationRequest, CreateDonationParams> {
  final DonationRepository repository;

  CreateDonationUseCase(this.repository);

  @override
  Future<Either<Failure, DonationRequest>> call(CreateDonationParams params) {
    return repository.createDonation(params);
  }
}
