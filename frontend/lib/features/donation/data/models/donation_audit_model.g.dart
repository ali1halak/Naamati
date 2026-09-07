// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation_audit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DonationAuditModel _$DonationAuditModelFromJson(Map<String, dynamic> json) =>
    DonationAuditModel(
      orderInfo: OrderInfoModel.fromJson(
        json['order_info'] as Map<String, dynamic>,
      ),
      logisticsDetails: LogisticsDetailsModel.fromJson(
        json['logistics_details'] as Map<String, dynamic>,
      ),
      socialImpact: json['social_impact'] == null
          ? null
          : SocialImpactModel.fromJson(
              json['social_impact'] as Map<String, dynamic>,
            ),
      rating: json['rating'] == null
          ? null
          : RatingModel.fromJson(json['rating'] as Map<String, dynamic>),
      canRateCharity: json['can_rate_charity'] as bool,
    );

Map<String, dynamic> _$DonationAuditModelToJson(DonationAuditModel instance) =>
    <String, dynamic>{
      'order_info': instance.orderInfo,
      'logistics_details': instance.logisticsDetails,
      'social_impact': instance.socialImpact,
      'rating': instance.rating,
      'can_rate_charity': instance.canRateCharity,
    };

OrderInfoModel _$OrderInfoModelFromJson(Map<String, dynamic> json) =>
    OrderInfoModel(
      orderNumber: json['order_number'] as String,
      title: json['title'] as String?,
      status: json['status'] as String,
      statusLabel: json['status_label'] as String,
      foodType: json['food_type'] as String?,
      foodCondition: json['food_condition'] as String?,
      expiryDate: json['expiry_date'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$OrderInfoModelToJson(OrderInfoModel instance) =>
    <String, dynamic>{
      'order_number': instance.orderNumber,
      'title': instance.title,
      'status': instance.status,
      'status_label': instance.statusLabel,
      'food_type': instance.foodType,
      'food_condition': instance.foodCondition,
      'expiry_date': instance.expiryDate,
      'quantity': instance.quantity,
      'description': instance.description,
    };

LogisticsDetailsModel _$LogisticsDetailsModelFromJson(
  Map<String, dynamic> json,
) => LogisticsDetailsModel(
  charityId: (json['charity_id'] as num?)?.toInt(),
  charityName: json['charity_name'] as String?,
  pickupAddress: json['pickup_address'] as String?,
  submittedAt: json['submitted_at'] as String?,
  acceptedAt: json['accepted_at'] as String?,
  pickedUpAt: json['picked_up_at'] as String?,
  completedAt: json['completed_at'] as String?,
  submittedAtIso: json['submitted_at_iso'] == null
      ? null
      : DateTime.parse(json['submitted_at_iso'] as String),
  acceptedAtIso: json['accepted_at_iso'] == null
      ? null
      : DateTime.parse(json['accepted_at_iso'] as String),
  pickedUpAtIso: json['picked_up_at_iso'] == null
      ? null
      : DateTime.parse(json['picked_up_at_iso'] as String),
  completedAtIso: json['completed_at_iso'] == null
      ? null
      : DateTime.parse(json['completed_at_iso'] as String),
);

Map<String, dynamic> _$LogisticsDetailsModelToJson(
  LogisticsDetailsModel instance,
) => <String, dynamic>{
  'charity_id': instance.charityId,
  'charity_name': instance.charityName,
  'pickup_address': instance.pickupAddress,
  'submitted_at': instance.submittedAt,
  'accepted_at': instance.acceptedAt,
  'picked_up_at': instance.pickedUpAt,
  'completed_at': instance.completedAt,
  'submitted_at_iso': instance.submittedAtIso?.toIso8601String(),
  'accepted_at_iso': instance.acceptedAtIso?.toIso8601String(),
  'picked_up_at_iso': instance.pickedUpAtIso?.toIso8601String(),
  'completed_at_iso': instance.completedAtIso?.toIso8601String(),
};

SocialImpactModel _$SocialImpactModelFromJson(Map<String, dynamic> json) =>
    SocialImpactModel(
      beneficiaryFamilies: (json['beneficiary_families'] as num).toInt(),
      beneficiaryIndividuals: (json['beneficiary_individuals'] as num).toInt(),
      distributionZone: json['distribution_zone'] as String,
      notes: json['notes'] as String?,
      distributedAt: json['distributed_at'] as String?,
    );

Map<String, dynamic> _$SocialImpactModelToJson(SocialImpactModel instance) =>
    <String, dynamic>{
      'beneficiary_families': instance.beneficiaryFamilies,
      'beneficiary_individuals': instance.beneficiaryIndividuals,
      'distribution_zone': instance.distributionZone,
      'notes': instance.notes,
      'distributed_at': instance.distributedAt,
    };
