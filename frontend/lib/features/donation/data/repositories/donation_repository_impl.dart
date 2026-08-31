import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/donation_request.dart';
import '../../domain/entities/donation_status.dart';
import '../../domain/entities/food_category.dart';
import '../../domain/entities/rating.dart';
import '../../domain/params/create_donation_params.dart';
import '../../domain/repositories/donation_repository.dart';
import '../datasources/donation_remote_data_source.dart';

@LazySingleton(as: DonationRepository)
class DonationRepositoryImpl implements DonationRepository {
  final DonationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DonationRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<FoodCategory>>> getFoodCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getFoodCategories();
        if (response.success) {
          return Right(response.data);
        }
        return Left(ServerFailure(message: response.message ?? 'فشل تحميل أنواع الطعام'));
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DonationRequest>> createDonation(CreateDonationParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.createDonation(
          foodCategoryId: params.foodCategoryId,
          needsCooking: params.needsCooking,
          quantityDesc: params.quantityDesc,
          description: params.description,
          validUntil: params.validUntil.toIso8601String(),
          pickupUntil: params.pickupUntil.toIso8601String(),
          pickupAddress: params.pickupAddress,
          latitude: params.latitude,
          longitude: params.longitude,
          contactPhone: params.contactPhone,
        );
        if (response.success) {
          return Right(response.data);
        }
        return Left(ServerFailure(message: response.message ?? 'فشل إنشاء طلب التبرع'));
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<DonationRequest>>> getMyDonations({DonationStatus? status}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getDonations(status: status?.wireName);
        if (response.success) {
          return Right(response.data.data);
        }
        return Left(ServerFailure(message: response.message ?? 'فشل تحميل التبرعات'));
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DonationRequest>> getDonationDetails(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getDonation(id);
        if (response.success) {
          return Right(response.data);
        }
        return Left(ServerFailure(message: response.message ?? 'فشل تحميل تفاصيل الطلب'));
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DonationRequest>> cancelDonation(int id, {String? reason}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.cancelDonation(id, reason: reason);
        if (response.success) {
          return Right(response.data);
        }
        return Left(ServerFailure(message: response.message ?? 'فشل إلغاء الطلب'));
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DonationRequest>> confirmPickup(int id, {required String qrToken}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.confirmPickup(id, qrToken: qrToken);
        if (response.success) {
          return Right(response.data);
        }
        return Left(ServerFailure(message: response.message ?? 'فشل تأكيد التسليم'));
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Rating>> rateDonation(int id, {required int stars, String? comment}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.rateDonation(id, stars: stars, comment: comment);
        if (response.success && response.data != null) {
          return Right(response.data!);
        }
        return Left(ServerFailure(message: response.message ?? 'فشل إرسال التقييم'));
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
