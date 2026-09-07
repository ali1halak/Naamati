import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../donation/domain/entities/donation_request.dart';
import '../repositories/charity_repository.dart';

/// "حفظ البيانات" — how many people the food reached (filed now or later).
@lazySingleton
class RecordImpactUseCase
    implements UseCase<DonationRequest, RecordImpactParams> {
  final CharityRepository repository;

  RecordImpactUseCase(this.repository);

  @override
  Future<Either<Failure, DonationRequest>> call(RecordImpactParams params) {
    return repository.recordImpact(
      params.id,
      familiesCount: params.familiesCount,
      individualsCount: params.individualsCount,
      area: params.area,
      notes: params.notes,
      distributedAt: params.distributedAt,
    );
  }
}

class RecordImpactParams extends Equatable {
  final int id;
  final int familiesCount;
  final int individualsCount;
  final String area;
  final String? notes;
  final DateTime? distributedAt;

  const RecordImpactParams({
    required this.id,
    required this.familiesCount,
    required this.individualsCount,
    required this.area,
    this.notes,
    this.distributedAt,
  });

  @override
  List<Object?> get props => [
    id,
    familiesCount,
    individualsCount,
    area,
    notes,
    distributedAt,
  ];
}
