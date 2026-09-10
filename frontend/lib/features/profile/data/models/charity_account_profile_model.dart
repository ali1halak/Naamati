import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/charity_account_profile.dart';

part 'charity_account_profile_model.g.dart';

@JsonSerializable()
class CharityAccountProfileModel extends CharityAccountProfile {
  const CharityAccountProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.address,
    super.latitude,
    super.longitude,
    @JsonKey(name: 'work_start') required super.workStart,
    @JsonKey(name: 'work_end') required super.workEnd,
    @JsonKey(name: 'has_kitchen') required super.hasKitchen,
    required super.status,
    @JsonKey(name: 'status_label') required super.statusLabel,
    @JsonKey(name: 'logo_url') super.logoUrl,
    @JsonKey(name: 'rating_avg') super.ratingAvg,
    @JsonKey(name: 'ratings_count') super.ratingsCount = 0,
    @JsonKey(name: 'completed_donations_count')
    super.completedDonationsCount = 0,
    @JsonKey(name: 'member_since') super.memberSince,
    @JsonKey(name: 'created_at') super.createdAt,
  });

  factory CharityAccountProfileModel.fromJson(Map<String, dynamic> json) =>
      _$CharityAccountProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$CharityAccountProfileModelToJson(this);
}
