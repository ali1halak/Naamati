import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    super.name,
    super.type,
    super.email,
    super.phone,
    @JsonKey(includeFromJson: false, includeToJson: false) super.accountType,
    super.status,
    @JsonKey(name: 'created_at') super.createdAt,
    @JsonKey(name: 'updated_at') super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
