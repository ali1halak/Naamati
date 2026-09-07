import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../donation/domain/entities/donation_request.dart';
import '../repositories/charity_repository.dart';

@lazySingleton
class AcceptRequestUseCase
    implements UseCase<DonationRequest, AcceptRequestParams> {
  final CharityRepository repository;

  AcceptRequestUseCase(this.repository);

  @override
  Future<Either<Failure, DonationRequest>> call(AcceptRequestParams params) {
    return repository.acceptRequest(params.id, etaMinutes: params.etaMinutes);
  }
}

class AcceptRequestParams extends Equatable {
  final int id;
  final int etaMinutes;

  const AcceptRequestParams({required this.id, required this.etaMinutes});

  @override
  List<Object?> get props => [id, etaMinutes];
}
