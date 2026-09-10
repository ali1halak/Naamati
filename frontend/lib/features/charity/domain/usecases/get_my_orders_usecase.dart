import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../donation/domain/entities/paginated_donations.dart';
import '../repositories/charity_repository.dart';

@lazySingleton
class GetMyOrdersUseCase
    implements UseCase<PaginatedDonations, GetMyOrdersParams> {
  final CharityRepository repository;

  GetMyOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedDonations>> call(GetMyOrdersParams params) {
    return repository.getMyOrders(status: params.status, page: params.page);
  }
}

class GetMyOrdersParams extends Equatable {
  /// One of the raw `RequestStatus` values, or the `active`/`cancelled_group`
  /// aliases; null means no filter.
  final String? status;

  /// 1-based page to fetch.
  final int page;

  const GetMyOrdersParams({this.status, this.page = 1});

  @override
  List<Object?> get props => [status, page];
}
