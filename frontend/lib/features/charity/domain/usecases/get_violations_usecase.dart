import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/violation.dart';
import '../repositories/charity_repository.dart';

@lazySingleton
class GetViolationsUseCase
    implements UseCase<PaginatedViolations, GetViolationsParams> {
  final CharityRepository repository;

  GetViolationsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedViolations>> call(
    GetViolationsParams params,
  ) {
    return repository.getViolations(page: params.page);
  }
}

class GetViolationsParams extends Equatable {
  /// 1-based page to fetch.
  final int page;

  const GetViolationsParams({this.page = 1});

  @override
  List<Object?> get props => [page];
}
