import 'package:json_annotation/json_annotation.dart';

import 'donation_request_model.dart';
import 'food_category_model.dart';
import 'rating_model.dart';

part 'donation_responses.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// API envelope models for the donation endpoints.
// Every backend response is `{ success, data, message }`.
// ─────────────────────────────────────────────────────────────────────────────

/// Envelope for single-donation endpoints (create / show / cancel / confirm).
@JsonSerializable()
class DonationResponseModel {
  final bool success;
  final DonationRequestModel data;
  final String? message;

  const DonationResponseModel({required this.success, required this.data, this.message});

  factory DonationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DonationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DonationResponseModelToJson(this);
}

/// Envelope for `GET /donor/requests` — Laravel paginated collection.
@JsonSerializable()
class DonationListResponseModel {
  final bool success;
  final DonationListDataModel data;
  final String? message;

  const DonationListResponseModel({required this.success, required this.data, this.message});

  factory DonationListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DonationListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DonationListResponseModelToJson(this);
}

/// Paginated payload: `{ data: [...rows], links: {...}, meta: {...} }`.
@JsonSerializable()
class DonationListDataModel {
  final List<DonationRequestModel> data;
  final DonationPaginationMetaModel? meta;

  const DonationListDataModel({required this.data, this.meta});

  factory DonationListDataModel.fromJson(Map<String, dynamic> json) =>
      _$DonationListDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$DonationListDataModelToJson(this);
}

@JsonSerializable()
class DonationPaginationMetaModel {
  @JsonKey(name: 'current_page')
  final int? currentPage;

  @JsonKey(name: 'last_page')
  final int? lastPage;

  @JsonKey(name: 'per_page')
  final int? perPage;

  final int? total;

  const DonationPaginationMetaModel({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory DonationPaginationMetaModel.fromJson(Map<String, dynamic> json) =>
      _$DonationPaginationMetaModelFromJson(json);

  Map<String, dynamic> toJson() => _$DonationPaginationMetaModelToJson(this);
}

/// Envelope for `POST /donor/requests/{id}/rate` (data = the created rating).
@JsonSerializable()
class RatingResponseModel {
  final bool success;
  final RatingModel? data;
  final String? message;

  const RatingResponseModel({required this.success, this.data, this.message});

  factory RatingResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RatingResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RatingResponseModelToJson(this);
}

/// Envelope for `GET /food-categories` (data = plain list).
@JsonSerializable()
class FoodCategoryListResponseModel {
  final bool success;
  final List<FoodCategoryModel> data;
  final String? message;

  const FoodCategoryListResponseModel({required this.success, required this.data, this.message});

  factory FoodCategoryListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FoodCategoryListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$FoodCategoryListResponseModelToJson(this);
}
