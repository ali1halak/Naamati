import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/rating.dart';
import '../repositories/donation_repository.dart';

@lazySingleton
class RateDonationUseCase implements UseCase<Rating, RateDonationParams> {
  final DonationRepository repository;

  RateDonationUseCase(this.repository);

  @override
  Future<Either<Failure, Rating>> call(RateDonationParams params) {
    return repository.rateDonation(params.id, stars: params.stars, comment: params.comment);
  }
}

class RateDonationParams extends Equatable {
  final int id;

  /// 1–5 stars.
  final int stars;

  final String? comment;

  const RateDonationParams({required this.id, required this.stars, this.comment});

  @override
  List<Object?> get props => [id, stars, comment];
}
