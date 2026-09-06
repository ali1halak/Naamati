import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/my_donations_filter.dart';
import '../entities/paginated_donations.dart';
import '../repositories/donation_repository.dart';

@lazySingleton
class GetMyDonationsUseCase
    implements UseCase<PaginatedDonations, GetMyDonationsParams> {
  final DonationRepository repository;

  GetMyDonationsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedDonations>> call(
    GetMyDonationsParams params,
  ) {
    return repository.getMyDonations(params.filter, page: params.page);
  }
}

class GetMyDonationsParams extends Equatable {
  final MyDonationsFilter filter;

  /// 1-based page to fetch.
  final int page;

  const GetMyDonationsParams({
    this.filter = MyDonationsFilter.empty,
    this.page = 1,
  });

  @override
  List<Object?> get props => [filter, page];
}
