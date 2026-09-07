// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charity_order_audit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharityOrderAuditModel _$CharityOrderAuditModelFromJson(
  Map<String, dynamic> json,
) => CharityOrderAuditModel(
  orderId: json['order_id'] as String,
  id: (json['id'] as num).toInt(),
  status: json['status'] as String,
  statusLabel: json['status_label'] as String,
  donor: CharityOrderDonorInfoModel.fromJson(
    json['donor'] as Map<String, dynamic>,
  ),
  donation: CharityOrderDonationInfoModel.fromJson(
    json['donation'] as Map<String, dynamic>,
  ),
  pickup: CharityOrderPickupInfoModel.fromJson(
    json['pickup'] as Map<String, dynamic>,
  ),
  distribution: json['distribution'] == null
      ? null
      : CharityOrderDistributionInfoModel.fromJson(
          json['distribution'] as Map<String, dynamic>,
        ),
  cancelReason: json['cancel_reason'] as String?,
);

Map<String, dynamic> _$CharityOrderAuditModelToJson(
  CharityOrderAuditModel instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'id': instance.id,
  'status': instance.status,
  'status_label': instance.statusLabel,
  'donor': instance.donor,
  'donation': instance.donation,
  'pickup': instance.pickup,
  'distribution': instance.distribution,
  'cancel_reason': instance.cancelReason,
};

CharityOrderDonorInfoModel _$CharityOrderDonorInfoModelFromJson(
  Map<String, dynamic> json,
) => CharityOrderDonorInfoModel(
  name: json['name'] as String?,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$CharityOrderDonorInfoModelToJson(
  CharityOrderDonorInfoModel instance,
) => <String, dynamic>{'name': instance.name, 'phone': instance.phone};

CharityOrderDonationInfoModel _$CharityOrderDonationInfoModelFromJson(
  Map<String, dynamic> json,
) => CharityOrderDonationInfoModel(
  category: json['category'] as String?,
  categoryIcon: json['category_icon'] as String?,
  foodCondition: json['food_condition'] as String?,
  quantity: (json['quantity'] as num?)?.toInt(),
  description: json['description'] as String?,
  expiryDate: json['expiry_date'] as String?,
  createdAt: json['created_at_iso'] as String?,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
);

Map<String, dynamic> _$CharityOrderDonationInfoModelToJson(
  CharityOrderDonationInfoModel instance,
) => <String, dynamic>{
  'category': instance.category,
  'category_icon': instance.categoryIcon,
  'food_condition': instance.foodCondition,
  'quantity': instance.quantity,
  'description': instance.description,
  'expiry_date': instance.expiryDate,
  'created_at_iso': instance.createdAt,
  'images': instance.images,
};

CharityOrderPickupInfoModel _$CharityOrderPickupInfoModelFromJson(
  Map<String, dynamic> json,
) => CharityOrderPickupInfoModel(
  acceptedAt: json['accepted_at'] as String?,
  actualPickupAt: json['actual_pickup_at'] as String?,
  deadline: json['deadline'] as String?,
  location: json['location'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
);

Map<String, dynamic> _$CharityOrderPickupInfoModelToJson(
  CharityOrderPickupInfoModel instance,
) => <String, dynamic>{
  'accepted_at': instance.acceptedAt,
  'actual_pickup_at': instance.actualPickupAt,
  'deadline': instance.deadline,
  'location': instance.location,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'notes': instance.notes,
  'eta_minutes': instance.etaMinutes,
};

CharityOrderDistributionInfoModel _$CharityOrderDistributionInfoModelFromJson(
  Map<String, dynamic> json,
) => CharityOrderDistributionInfoModel(
  beneficiaryFamilies: (json['beneficiary_families'] as num).toInt(),
  beneficiaryIndividuals: (json['beneficiary_individuals'] as num).toInt(),
  distributionZone: json['distribution_zone'] as String,
  notes: json['notes'] as String?,
  distributedAt: json['distributed_at'] as String?,
);

Map<String, dynamic> _$CharityOrderDistributionInfoModelToJson(
  CharityOrderDistributionInfoModel instance,
) => <String, dynamic>{
  'beneficiary_families': instance.beneficiaryFamilies,
  'beneficiary_individuals': instance.beneficiaryIndividuals,
  'distribution_zone': instance.distributionZone,
  'notes': instance.notes,
  'distributed_at': instance.distributedAt,
};
