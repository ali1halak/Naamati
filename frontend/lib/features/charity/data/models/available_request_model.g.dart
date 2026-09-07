// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableRequestModel _$AvailableRequestModelFromJson(
  Map<String, dynamic> json,
) => AvailableRequestModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String?,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  categoryIcon: json['category_icon'] as String?,
  quantityDesc: json['quantity_desc'] as String?,
  needsCooking: json['needs_cooking'] as bool,
  expiryDate: json['expiry_date'] as String?,
  pickupDeadline: json['pickup_deadline'] as String?,
  createdAtLabel: json['created_at_label'] as String?,
  validUntil: json['valid_until_iso'] == null
      ? null
      : DateTime.parse(json['valid_until_iso'] as String),
  pickupUntil: json['pickup_until_iso'] == null
      ? null
      : DateTime.parse(json['pickup_until_iso'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  locationZone: json['location_zone'] as String?,
  pickupNotes: json['pickup_notes'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$AvailableRequestModelToJson(
  AvailableRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'image_url': instance.imageUrl,
  'images': instance.images,
  'category_icon': instance.categoryIcon,
  'quantity_desc': instance.quantityDesc,
  'needs_cooking': instance.needsCooking,
  'expiry_date': instance.expiryDate,
  'pickup_deadline': instance.pickupDeadline,
  'created_at_label': instance.createdAtLabel,
  'valid_until_iso': instance.validUntil?.toIso8601String(),
  'pickup_until_iso': instance.pickupUntil?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'location_zone': instance.locationZone,
  'pickup_notes': instance.pickupNotes,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
