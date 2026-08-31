import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/charity_profile.dart';

part 'charity_card_model.g.dart';

/// Charity profile as embedded in a donation response
/// (backend `CharityCardResource`).
@JsonSerializable()
class CharityCardModel extends CharityProfile {
  const CharityCardModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.address,
    @JsonKey(name: 'logo_url') super.logoUrl,
    @JsonKey(name: 'rating_avg') super.ratingAvg,
    @JsonKey(name: 'ratings_count') required super.ratingsCount,
    @JsonKey(name: 'completed_donations_count') required super.completedDonationsCount,
  });

  factory CharityCardModel.fromJson(Map<String, dynamic> json) =>
      _$CharityCardModelFromJson(json);

  Map<String, dynamic> toJson() => _$CharityCardModelToJson(this);
}
