import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../donation/domain/entities/donation_request.dart';
import '../repositories/charity_repository.dart';

/// "تأكيد التوزيع" — the food has been handed out; closes the request.
@lazySingleton
class ConfirmDistributionUseCase
    implements UseCase<DonationRequest, ConfirmDistributionParams> {
  final CharityRepository repository;

  ConfirmDistributionUseCase(this.repository);

  @override
  Future<Either<Failure, DonationRequest>> call(
    ConfirmDistributionParams params,
  ) {
    return repository.confirmDistribution(params.id);
  }
}

class ConfirmDistributionParams extends Equatable {
  final int id;

  const ConfirmDistributionParams({required this.id});

  @override
  List<Object?> get props => [id];
}
