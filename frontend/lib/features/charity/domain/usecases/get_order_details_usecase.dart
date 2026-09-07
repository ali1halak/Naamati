import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../donation/domain/entities/donation_request.dart';
import '../repositories/charity_repository.dart';

@lazySingleton
class GetOrderDetailsUseCase
    implements UseCase<DonationRequest, GetOrderDetailsParams> {
  final CharityRepository repository;

  GetOrderDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, DonationRequest>> call(GetOrderDetailsParams params) {
    return repository.getOrderDetails(params.id);
  }
}

class GetOrderDetailsParams extends Equatable {
  final int id;

  const GetOrderDetailsParams({required this.id});

  @override
  List<Object?> get props => [id];
}
