import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/donation_request.dart';
import '../repositories/donation_repository.dart';

@lazySingleton
class ConfirmPickupUseCase
    implements UseCase<DonationRequest, ConfirmPickupParams> {
  final DonationRepository repository;

  ConfirmPickupUseCase(this.repository);

  @override
  Future<Either<Failure, DonationRequest>> call(ConfirmPickupParams params) {
    return repository.confirmPickup(params.id);
  }
}

class ConfirmPickupParams extends Equatable {
  final int id;

  const ConfirmPickupParams({required this.id});

  @override
  List<Object?> get props => [id];
}
