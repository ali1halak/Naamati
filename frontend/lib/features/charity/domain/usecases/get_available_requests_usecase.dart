import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_available_requests.dart';
import '../repositories/charity_repository.dart';

@lazySingleton
class GetAvailableRequestsUseCase
    implements UseCase<PaginatedAvailableRequests, GetAvailableRequestsParams> {
  final CharityRepository repository;

  GetAvailableRequestsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedAvailableRequests>> call(
    GetAvailableRequestsParams params,
  ) {
    return repository.getAvailableRequests(page: params.page);
  }
}

class GetAvailableRequestsParams extends Equatable {
  final int page;

  const GetAvailableRequestsParams({this.page = 1});

  @override
  List<Object?> get props => [page];
}
