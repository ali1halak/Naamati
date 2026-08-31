import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/donation_request.dart';
import '../entities/donation_status.dart';
import '../repositories/donation_repository.dart';

@lazySingleton
class GetMyDonationsUseCase implements UseCase<List<DonationRequest>, GetMyDonationsParams> {
  final DonationRepository repository;

  GetMyDonationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DonationRequest>>> call(GetMyDonationsParams params) {
    return repository.getMyDonations(status: params.status);
  }
}

class GetMyDonationsParams extends Equatable {
  final DonationStatus? status;

  const GetMyDonationsParams({this.status});

  @override
  List<Object?> get props => [status];
}
