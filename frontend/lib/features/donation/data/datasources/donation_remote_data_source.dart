import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/donation_responses.dart';

part 'donation_remote_data_source.g.dart';

/// Donor-side donation API (`/api/v1/donor/*`).
///
/// Dates are sent ISO-8601 with local offset (e.g.
/// `2026-09-01T18:00:00+03:00`) so the backend validates and stores the
/// correct instant and the round-trip back to local time is lossless.
@RestApi()
abstract class DonationRemoteDataSource {
  @factoryMethod
  factory DonationRemoteDataSource(Dio dio) = _DonationRemoteDataSource;

  // ── Reference data ──────────────────────────────────────────────────────────

  @GET('/food-categories')
  Future<FoodCategoryListResponseModel> getFoodCategories();

  // ── Donation requests ───────────────────────────────────────────────────────

  @GET('/donor/requests')
  Future<DonationListResponseModel> getDonations({@Query('status') String? status});

  @POST('/donor/requests')
  Future<DonationResponseModel> createDonation({
    @Field('food_category_id') required int foodCategoryId,
    @Field('needs_cooking') required bool needsCooking,
    @Field('quantity_desc') required String quantityDesc,
    @Field('description') String? description,
    @Field('valid_until') required String validUntil,
    @Field('pickup_until') required String pickupUntil,
    @Field('pickup_address') required String pickupAddress,
    @Field('latitude') double? latitude,
    @Field('longitude') double? longitude,
    @Field('contact_phone') required String contactPhone,
  });

  @GET('/donor/requests/{id}')
  Future<DonationResponseModel> getDonation(@Path() int id);

  @POST('/donor/requests/{id}/cancel')
  Future<DonationResponseModel> cancelDonation(
    @Path() int id, {
    @Field('reason') String? reason,
  });

  @POST('/donor/requests/{id}/confirm')
  Future<DonationResponseModel> confirmPickup(
    @Path() int id, {
    @Field('qr_token') required String qrToken,
  });

  @POST('/donor/requests/{id}/rate')
  Future<RatingResponseModel> rateDonation(
    @Path() int id, {
    @Field('stars') required int stars,
    @Field('comment') String? comment,
  });
}
