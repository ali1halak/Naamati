import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/donation_request.dart';
import '../entities/donation_status.dart';
import '../entities/food_category.dart';
import '../entities/rating.dart';
import '../params/create_donation_params.dart';

/// Donor-side donation contracts (backend: `/api/v1/donor/*`).
abstract class DonationRepository {
  /// Reference list of food categories (`GET /food-categories`).
  Future<Either<Failure, List<FoodCategory>>> getFoodCategories();

  /// Publish a new donation request (`POST /donor/requests`, 201).
  Future<Either<Failure, DonationRequest>> createDonation(CreateDonationParams params);

  /// List the donor's own donations, optionally filtered by status
  /// (`GET /donor/requests?status=…`, paginated 15/page — first page).
  Future<Either<Failure, List<DonationRequest>>> getMyDonations({DonationStatus? status});

  /// Full detail of one owned donation (`GET /donor/requests/{id}`).
  Future<Either<Failure, DonationRequest>> getDonationDetails(int id);

  /// Cancel from `pending`/`accepted` (`POST /donor/requests/{id}/cancel`).
  Future<Either<Failure, DonationRequest>> cancelDonation(int id, {String? reason});

  /// Confirm the handover using the QR token the charity presents
  /// (`POST /donor/requests/{id}/confirm`, `accepted` → `picked_up`).
  Future<Either<Failure, DonationRequest>> confirmPickup(int id, {required String qrToken});

  /// Rate the charity after pickup (`POST /donor/requests/{id}/rate`, 201).
  Future<Either<Failure, Rating>> rateDonation(int id, {required int stars, String? comment});
}
