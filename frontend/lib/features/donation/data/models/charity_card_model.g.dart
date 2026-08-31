// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charity_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharityCardModel _$CharityCardModelFromJson(Map<String, dynamic> json) =>
    CharityCardModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      logoUrl: json['logo_url'] as String?,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble(),
      ratingsCount: (json['ratings_count'] as num).toInt(),
      completedDonationsCount: (json['completed_donations_count'] as num)
          .toInt(),
    );

Map<String, dynamic> _$CharityCardModelToJson(CharityCardModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
      'logo_url': instance.logoUrl,
      'rating_avg': instance.ratingAvg,
      'ratings_count': instance.ratingsCount,
      'completed_donations_count': instance.completedDonationsCount,
    };
