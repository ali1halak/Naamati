import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/donation_request.dart';
import '../repositories/donation_repository.dart';

@lazySingleton
class CancelDonationUseCase implements UseCase<DonationRequest, CancelDonationParams> {
  final DonationRepository repository;

  CancelDonationUseCase(this.repository);

  @override
  Future<Either<Failure, DonationRequest>> call(CancelDonationParams params) {
    return repository.cancelDonation(params.id, reason: params.reason);
  }
}

class CancelDonationParams extends Equatable {
  final int id;
  final String? reason;

  const CancelDonationParams({required this.id, this.reason});

  @override
  List<Object?> get props => [id, reason];
}
