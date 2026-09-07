import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../../donation/domain/entities/donation_request.dart';
import '../../domain/entities/paginated_available_requests.dart';
import '../../domain/repositories/charity_repository.dart';
import '../datasources/charity_remote_data_source.dart';

@LazySingleton(as: CharityRepository)
class CharityRepositoryImpl implements CharityRepository {
  final CharityRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CharityRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedAvailableRequests>> getAvailableRequests({
    int page = 1,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getAvailableRequests(
          page: page,
        );
        if (response.success) {
          final payload = response.data;
          final meta = payload.meta;
          return Right(
            PaginatedAvailableRequests(
              items: payload.data,
              currentPage: meta?.currentPage ?? page,
              lastPage: meta?.lastPage ?? page,
            ),
          );
        }
        return Left(
          ServerFailure(
            message: response.message ?? 'فشل تحميل الطلبات المتاحة',
          ),
        );
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DonationRequest>> acceptRequest(
    int id, {
    required int etaMinutes,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.acceptRequest(
          id,
          etaMinutes: etaMinutes,
        );
        if (response.success) {
          return Right(response.data);
        }
        return Left(
          ServerFailure(message: response.message ?? 'فشل قبول الطلب'),
        );
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DonationRequest>> getOrderDetails(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getOrderDetails(id);
        if (response.success) {
          return Right(response.data);
        }
        return Left(
          ServerFailure(message: response.message ?? 'فشل تحميل تفاصيل الطلب'),
        );
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DonationRequest>> confirmPickup(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.confirmPickup(id);
        if (response.success) {
          return Right(response.data);
        }
        return Left(
          ServerFailure(message: response.message ?? 'فشل تأكيد الأخذ'),
        );
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DonationRequest>> confirmDistribution(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.confirmDistribution(id);
        if (response.success) {
          return Right(response.data);
        }
        return Left(
          ServerFailure(message: response.message ?? 'فشل تأكيد التوزيع'),
        );
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DonationRequest>> recordImpact(
    int id, {
    required int familiesCount,
    required int individualsCount,
    required String area,
    String? notes,
    DateTime? distributedAt,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.recordImpact(
          id,
          familiesCount: familiesCount,
          individualsCount: individualsCount,
          area: area,
          notes: notes,
          distributedAt: distributedAt?.toIso8601String(),
        );
        if (response.success) {
          return Right(response.data);
        }
        return Left(
          ServerFailure(message: response.message ?? 'فشل حفظ بيانات التوزيع'),
        );
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
