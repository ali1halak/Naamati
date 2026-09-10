// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charity_account_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharityAccountProfileModel _$CharityAccountProfileModelFromJson(
  Map<String, dynamic> json,
) => CharityAccountProfileModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  workStart: json['work_start'] as String,
  workEnd: json['work_end'] as String,
  hasKitchen: json['has_kitchen'] as bool,
  status: json['status'] as String,
  statusLabel: json['status_label'] as String,
  logoUrl: json['logo_url'] as String?,
  ratingAvg: (json['rating_avg'] as num?)?.toDouble(),
  ratingsCount: (json['ratings_count'] as num?)?.toInt() ?? 0,
  completedDonationsCount:
      (json['completed_donations_count'] as num?)?.toInt() ?? 0,
  memberSince: json['member_since'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CharityAccountProfileModelToJson(
  CharityAccountProfileModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'work_start': instance.workStart,
  'work_end': instance.workEnd,
  'has_kitchen': instance.hasKitchen,
  'status': instance.status,
  'status_label': instance.statusLabel,
  'logo_url': instance.logoUrl,
  'rating_avg': instance.ratingAvg,
  'ratings_count': instance.ratingsCount,
  'completed_donations_count': instance.completedDonationsCount,
  'member_since': instance.memberSince,
  'created_at': instance.createdAt?.toIso8601String(),
};
