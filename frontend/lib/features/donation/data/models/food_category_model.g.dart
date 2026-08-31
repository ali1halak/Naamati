// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodCategoryModel _$FoodCategoryModelFromJson(Map<String, dynamic> json) =>
    FoodCategoryModel(
      id: (json['id'] as num).toInt(),
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      defaultNeedsCooking: json['default_needs_cooking'] as bool,
    );

Map<String, dynamic> _$FoodCategoryModelToJson(FoodCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_ar': instance.nameAr,
      'name_en': instance.nameEn,
      'default_needs_cooking': instance.defaultNeedsCooking,
    };
