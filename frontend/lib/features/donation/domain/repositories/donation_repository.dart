import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/donation_audit.dart';
import '../entities/donation_request.dart';
import '../entities/food_category.dart';
import '../entities/my_donations_filter.dart';
import '../entities/paginated_donations.dart';
import '../entities/rating.dart';
import '../params/create_donation_params.dart';

/// Donor-side donation contracts (backend: `/api/v1/donor/*`).
abstract class DonationRepository {
  /// Reference list of food categories (`GET /food-categories`).
  Future<Either<Failure, List<FoodCategory>>> getFoodCategories();

  /// Publish a new donation request (`POST /donor/requests`, 201).
  Future<Either<Failure, DonationRequest>> createDonation(
    CreateDonationParams params,
  );

  /// Rewrite the donor-authored fields of a still-pending request
  /// (`PUT /donor/requests/{id}`).
  Future<Either<Failure, DonationRequest>> updateDonation(
    int id,
    CreateDonationParams params,
  );

  /// One page of the donor's own donations with the given filters
  /// (`GET /donor/requests?…`, paginated 15/page).
  Future<Either<Failure, PaginatedDonations>> getMyDonations(
    MyDonationsFilter filter, {
    int page,
  });

  /// Full detail of one owned donation (`GET /donor/requests/{id}`).
  Future<Either<Failure, DonationRequest>> getDonationDetails(int id);

  /// Detailed audit of one owned donation (`GET /donor/requests/{id}/audit`).
  Future<Either<Failure, DonationAudit>> getDonationAudit(int id);

  /// Cancel from `pending`/`accepted` (`POST /donor/requests/{id}/cancel`).
  Future<Either<Failure, DonationRequest>> cancelDonation(
    int id, {
    String? reason,
  });

  /// Confirm the handover using the QR token the charity presents
  /// (`POST /donor/requests/{id}/confirm`, `accepted` → `picked_up`).
  Future<Either<Failure, DonationRequest>> confirmPickup(int id);

  /// Rate the charity after pickup (`POST /donor/requests/{id}/rate`, 201).
  Future<Either<Failure, Rating>> rateDonation(
    int id, {
    required int stars,
    String? comment,
  });
}
