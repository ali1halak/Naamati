// Nested model fields are redeclared with their concrete types so
// json_serializable generates the nested fromJson/toJson calls, while still
// being forwarded to the entity constructor.
// ignore_for_file: overridden_fields
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/donation_audit.dart';
import 'rating_model.dart';

part 'donation_audit_model.g.dart';

@JsonSerializable()
class DonationAuditModel extends DonationAudit {
  @override
  @JsonKey(name: 'order_info')
  final OrderInfoModel orderInfo;

  @override
  @JsonKey(name: 'logistics_details')
  final LogisticsDetailsModel logisticsDetails;

  @override
  @JsonKey(name: 'social_impact')
  final SocialImpactModel? socialImpact;

  @override
  final RatingModel? rating;

  @override
  @JsonKey(name: 'can_rate_charity')
  final bool canRateCharity;

  const DonationAuditModel({
    required this.orderInfo,
    required this.logisticsDetails,
    this.socialImpact,
    this.rating,
    required this.canRateCharity,
  }) : super(
         orderInfo: orderInfo,
         logisticsDetails: logisticsDetails,
         socialImpact: socialImpact,
         rating: rating,
         canRateCharity: canRateCharity,
       );

  factory DonationAuditModel.fromJson(Map<String, dynamic> json) =>
      _$DonationAuditModelFromJson(json);

  Map<String, dynamic> toJson() => _$DonationAuditModelToJson(this);
}

@JsonSerializable()
class OrderInfoModel extends DonationOrderInfo {
  const OrderInfoModel({
    @JsonKey(name: 'order_number') required super.orderNumber,
    super.title,
    required super.status,
    @JsonKey(name: 'status_label') required super.statusLabel,
    @JsonKey(name: 'food_type') super.foodType,
    @JsonKey(name: 'food_condition') super.foodCondition,
    @JsonKey(name: 'expiry_date') super.expiryDate,
    @JsonKey(name: 'quantity') super.quantity,
    super.description,
  });

  factory OrderInfoModel.fromJson(Map<String, dynamic> json) =>
      _$OrderInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderInfoModelToJson(this);
}

@JsonSerializable()
class LogisticsDetailsModel extends DonationLogisticsDetails {
  const LogisticsDetailsModel({
    @JsonKey(name: 'charity_id') super.charityId,
    @JsonKey(name: 'charity_name') super.charityName,
    @JsonKey(name: 'pickup_address') super.pickupAddress,
    @JsonKey(name: 'submitted_at') super.submittedAt,
    @JsonKey(name: 'accepted_at') super.acceptedAt,
    @JsonKey(name: 'picked_up_at') super.pickedUpAt,
    @JsonKey(name: 'completed_at') super.completedAt,
    @JsonKey(name: 'submitted_at_iso') super.submittedAtIso,
    @JsonKey(name: 'accepted_at_iso') super.acceptedAtIso,
    @JsonKey(name: 'picked_up_at_iso') super.pickedUpAtIso,
    @JsonKey(name: 'completed_at_iso') super.completedAtIso,
  });

  factory LogisticsDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$LogisticsDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$LogisticsDetailsModelToJson(this);
}

@JsonSerializable()
class SocialImpactModel extends DonationSocialImpact {
  const SocialImpactModel({
    @JsonKey(name: 'beneficiary_families') required super.beneficiaryFamilies,
    @JsonKey(name: 'beneficiary_individuals')
    required super.beneficiaryIndividuals,
    @JsonKey(name: 'distribution_zone') required super.distributionZone,
    super.notes,
    @JsonKey(name: 'distributed_at') super.distributedAt,
  });

  factory SocialImpactModel.fromJson(Map<String, dynamic> json) =>
      _$SocialImpactModelFromJson(json);

  Map<String, dynamic> toJson() => _$SocialImpactModelToJson(this);
}
