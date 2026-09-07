// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donor_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DonorProfileModel _$DonorProfileModelFromJson(Map<String, dynamic> json) =>
    DonorProfileModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      type: json['type'] as String,
      avatarUrl: json['avatar_url'] as String?,
      completedDonationsCount:
          (json['completed_donations_count'] as num?)?.toInt() ?? 0,
      memberSince: json['member_since'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DonorProfileModelToJson(DonorProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'type': instance.type,
      'avatar_url': instance.avatarUrl,
      'completed_donations_count': instance.completedDonationsCount,
      'member_since': instance.memberSince,
      'created_at': instance.createdAt?.toIso8601String(),
    };
