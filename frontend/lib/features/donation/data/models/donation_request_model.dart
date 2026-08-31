// Nested model fields are redeclared with their concrete types so
// json_serializable generates the nested fromJson/toJson calls, while still
// being forwarded to the entity constructor.
// ignore_for_file: overridden_fields
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/donation_request.dart';
import '../../domain/entities/donation_status.dart';
import 'charity_card_model.dart';
import 'food_category_model.dart';
import 'rating_model.dart';

part 'donation_request_model.g.dart';

/// Serializable donation request (backend `DonationRequestResource`).
///
/// Nested [foodCategory], [charity] and [rating] are redeclared with their
/// model types so json_serializable generates the nested `fromJson` calls,
/// while still being forwarded to the entity constructor for equality.
@JsonSerializable()
class DonationRequestModel extends DonationRequest {
  @override
  @JsonKey(name: 'food_category')
  final FoodCategoryModel? foodCategory;

  @override
  @JsonKey(name: 'charity')
  final CharityCardModel? charity;

  @override
  final RatingModel? rating;

  const DonationRequestModel({
    required super.id,
    required super.status,
    this.foodCategory,
    @JsonKey(name: 'needs_cooking') required super.needsCooking,
    @JsonKey(name: 'quantity_desc') required super.quantityDesc,
    super.description,
    @JsonKey(name: 'valid_until') super.validUntil,
    @JsonKey(name: 'pickup_until') super.pickupUntil,
    @JsonKey(name: 'pickup_address') required super.pickupAddress,
    super.latitude,
    super.longitude,
    @JsonKey(name: 'contact_phone') required super.contactPhone,
    this.charity,
    @JsonKey(name: 'eta_minutes') super.etaMinutes,
    @JsonKey(name: 'accepted_at') super.acceptedAt,
    @JsonKey(name: 'picked_up_at') super.pickedUpAt,
    @JsonKey(name: 'cancel_reason') super.cancelReason,
    @JsonKey(name: 'created_at') super.createdAt,
    this.rating,
  }) : super(foodCategory: foodCategory, charity: charity, rating: rating);

  factory DonationRequestModel.fromJson(Map<String, dynamic> json) =>
      _$DonationRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$DonationRequestModelToJson(this);
}
