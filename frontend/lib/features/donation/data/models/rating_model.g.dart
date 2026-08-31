// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RatingModel _$RatingModelFromJson(Map<String, dynamic> json) => RatingModel(
  id: (json['id'] as num).toInt(),
  stars: (json['stars'] as num).toInt(),
  comment: json['comment'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$RatingModelToJson(RatingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stars': instance.stars,
      'comment': instance.comment,
      'created_at': instance.createdAt?.toIso8601String(),
    };
