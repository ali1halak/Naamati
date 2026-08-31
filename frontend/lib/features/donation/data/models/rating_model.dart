import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/rating.dart';

part 'rating_model.g.dart';

@JsonSerializable()
class RatingModel extends Rating {
  const RatingModel({
    required super.id,
    required super.stars,
    super.comment,
    @JsonKey(name: 'created_at') super.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) => _$RatingModelFromJson(json);

  Map<String, dynamic> toJson() => _$RatingModelToJson(this);
}
