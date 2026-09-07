import 'dart:io';

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
  Future<DonationListResponseModel> getDonations({
    @Query('search') String? search,
    @Query('status') String? status,
    @Query('category') int? categoryId,
    @Query('needs_cooking') bool? needsCooking,
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('page') int? page,
  });

  // Multipart: the request may carry up to 4 food photos.
  @MultiPart()
  @POST('/donor/requests')
  Future<DonationResponseModel> createDonation({
    @Part(name: 'food_category_id') required int foodCategoryId,
    @Part(name: 'needs_cooking') required bool needsCooking,
    @Part(name: 'quantity_desc') required String quantityDesc,
    @Part(name: 'description') String? description,
    @Part(name: 'custom_category') String? customCategory,
    @Part(name: 'valid_until') required String validUntil,
    @Part(name: 'pickup_until') required String pickupUntil,
    @Part(name: 'pickup_address') required String pickupAddress,
    @Part(name: 'pickup_notes') String? pickupNotes,
    @Part(name: 'latitude') double? latitude,
    @Part(name: 'longitude') double? longitude,
    @Part(name: 'contact_phone') required String contactPhone,
    // Bracketed name so PHP collects the repeated parts into an `images`
    // array; a plain `images` name makes Laravel see a single file instead.
    @Part(name: 'images[]')
    List<File>? images,
  });

  /// Multipart despite being an update: the donor may add photos here.
  /// Laravel method spoofing (`_method=PUT`) lets a POST carry the files —
  /// real PUT requests cannot have a multipart body in practice.
  @MultiPart()
  @POST('/donor/requests/{id}')
  Future<DonationResponseModel> updateDonation(
    @Path('id') int id, {
    @Part(name: '_method') required String method,
    @Part(name: 'food_category_id') required int foodCategoryId,
    @Part(name: 'needs_cooking') required bool needsCooking,
    @Part(name: 'quantity_desc') required String quantityDesc,
    @Part(name: 'description') String? description,
    @Part(name: 'custom_category') String? customCategory,
    @Part(name: 'valid_until') required String validUntil,
    @Part(name: 'pickup_until') required String pickupUntil,
    @Part(name: 'pickup_address') required String pickupAddress,
    @Part(name: 'pickup_notes') String? pickupNotes,
    @Part(name: 'latitude') double? latitude,
    @Part(name: 'longitude') double? longitude,
    @Part(name: 'contact_phone') required String contactPhone,
    // Ids of this request's existing photos to delete (one part per id,
    // `removed_image_ids[]`), plus newly added files.
    @Part(name: 'removed_image_ids[]') List<String>? removedImageIds,
    @Part(name: 'images[]') List<File>? images,
  });

  @GET('/donor/requests/{id}')
  Future<DonationResponseModel> getDonation(@Path() int id);

  @GET('/donor/requests/{id}/audit')
  Future<DonationAuditResponseModel> getDonationAudit(@Path() int id);

  @POST('/donor/requests/{id}/cancel')
  Future<DonationResponseModel> cancelDonation(
    @Path() int id, {
    @Field('reason') String? reason,
  });

  @POST('/donor/requests/{id}/confirm')
  Future<DonationResponseModel> confirmPickup(@Path() int id);

  @POST('/donor/requests/{id}/rate')
  Future<RatingResponseModel> rateDonation(
    @Path() int id, {
    @Field('stars') required int stars,
    @Field('comment') String? comment,
  });
}
