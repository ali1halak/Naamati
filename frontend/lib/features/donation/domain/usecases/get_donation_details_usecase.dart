import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/donation_request.dart';
import '../repositories/donation_repository.dart';

@lazySingleton
class GetDonationDetailsUseCase implements UseCase<DonationRequest, GetDonationDetailsParams> {
  final DonationRepository repository;

  GetDonationDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, DonationRequest>> call(GetDonationDetailsParams params) {
    return repository.getDonationDetails(params.id);
  }
}

class GetDonationDetailsParams extends Equatable {
  final int id;

  const GetDonationDetailsParams({required this.id});

  @override
  List<Object?> get props => [id];
}
