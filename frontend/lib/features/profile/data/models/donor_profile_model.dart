import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/donor_profile.dart';

part 'donor_profile_model.g.dart';

@JsonSerializable()
class DonorProfileModel extends DonorProfile {
  const DonorProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.type,
    @JsonKey(name: 'avatar_url') super.avatarUrl,
    @JsonKey(name: 'completed_donations_count')
    super.completedDonationsCount = 0,
    @JsonKey(name: 'member_since') super.memberSince,
    @JsonKey(name: 'created_at') super.createdAt,
  });

  factory DonorProfileModel.fromJson(Map<String, dynamic> json) =>
      _$DonorProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$DonorProfileModelToJson(this);
}
