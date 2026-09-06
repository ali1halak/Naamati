import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/donation_audit.dart';
import '../repositories/donation_repository.dart';

@lazySingleton
class GetDonationAuditUseCase
    implements UseCase<DonationAudit, GetDonationAuditParams> {
  final DonationRepository repository;

  GetDonationAuditUseCase(this.repository);

  @override
  Future<Either<Failure, DonationAudit>> call(GetDonationAuditParams params) {
    return repository.getDonationAudit(params.id);
  }
}

class GetDonationAuditParams extends Equatable {
  final int id;

  const GetDonationAuditParams({required this.id});

  @override
  List<Object?> get props => [id];
}
