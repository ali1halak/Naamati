// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DonationRequestModel _$DonationRequestModelFromJson(
  Map<String, dynamic> json,
) => DonationRequestModel(
  id: (json['id'] as num).toInt(),
  status: $enumDecode(_$DonationStatusEnumMap, json['status']),
  foodCategory: json['food_category'] == null
      ? null
      : FoodCategoryModel.fromJson(
          json['food_category'] as Map<String, dynamic>,
        ),
  needsCooking: json['needs_cooking'] as bool,
  quantityDesc: json['quantity_desc'] as String,
  description: json['description'] as String?,
  validUntil: json['valid_until'] == null
      ? null
      : DateTime.parse(json['valid_until'] as String),
  pickupUntil: json['pickup_until'] == null
      ? null
      : DateTime.parse(json['pickup_until'] as String),
  pickupAddress: json['pickup_address'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  contactPhone: json['contact_phone'] as String,
  charity: json['charity'] == null
      ? null
      : CharityCardModel.fromJson(json['charity'] as Map<String, dynamic>),
  etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
  acceptedAt: json['accepted_at'] == null
      ? null
      : DateTime.parse(json['accepted_at'] as String),
  pickedUpAt: json['picked_up_at'] == null
      ? null
      : DateTime.parse(json['picked_up_at'] as String),
  cancelReason: json['cancel_reason'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  rating: json['rating'] == null
      ? null
      : RatingModel.fromJson(json['rating'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DonationRequestModelToJson(
  DonationRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': _$DonationStatusEnumMap[instance.status]!,
  'needs_cooking': instance.needsCooking,
  'quantity_desc': instance.quantityDesc,
  'description': instance.description,
  'valid_until': instance.validUntil?.toIso8601String(),
  'pickup_until': instance.pickupUntil?.toIso8601String(),
  'pickup_address': instance.pickupAddress,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'contact_phone': instance.contactPhone,
  'eta_minutes': instance.etaMinutes,
  'accepted_at': instance.acceptedAt?.toIso8601String(),
  'picked_up_at': instance.pickedUpAt?.toIso8601String(),
  'cancel_reason': instance.cancelReason,
  'created_at': instance.createdAt?.toIso8601String(),
  'food_category': instance.foodCategory,
  'charity': instance.charity,
  'rating': instance.rating,
};

const _$DonationStatusEnumMap = {
  DonationStatus.pending: 'pending',
  DonationStatus.accepted: 'accepted',
  DonationStatus.pickedUp: 'picked_up',
  DonationStatus.completed: 'completed',
  DonationStatus.expired: 'expired',
  DonationStatus.cancelled: 'cancelled',
  DonationStatus.noShow: 'no_show',
};
