import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/food_category.dart';

part 'food_category_model.g.dart';

@JsonSerializable()
class FoodCategoryModel extends FoodCategory {
  const FoodCategoryModel({
    required super.id,
    @JsonKey(name: 'name_ar') required super.nameAr,
    @JsonKey(name: 'name_en') required super.nameEn,
    @JsonKey(name: 'default_needs_cooking') required super.defaultNeedsCooking,
  });

  factory FoodCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$FoodCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$FoodCategoryModelToJson(this);
}
