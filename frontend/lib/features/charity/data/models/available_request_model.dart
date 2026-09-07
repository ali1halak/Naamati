import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/available_request.dart';

part 'available_request_model.g.dart';

/// Serializable available-request card (backend `CharityOrderResource`).
@JsonSerializable()
class AvailableRequestModel extends AvailableRequest {
  const AvailableRequestModel({
    required super.id,
    super.title,
    super.description,
    @JsonKey(name: 'image_url') super.imageUrl,
    @JsonKey(defaultValue: []) super.images = const [],
    @JsonKey(name: 'category_icon') super.categoryIcon,
    @JsonKey(name: 'quantity_desc') super.quantityDesc,
    @JsonKey(name: 'needs_cooking') required super.needsCooking,
    @JsonKey(name: 'expiry_date') super.expiryDate,
    @JsonKey(name: 'pickup_deadline') super.pickupDeadline,
    @JsonKey(name: 'created_at_label') super.createdAtLabel,
    @JsonKey(name: 'valid_until_iso') super.validUntil,
    @JsonKey(name: 'pickup_until_iso') super.pickupUntil,
    @JsonKey(name: 'created_at') super.createdAt,
    @JsonKey(name: 'location_zone') super.locationZone,
    @JsonKey(name: 'pickup_notes') super.pickupNotes,
    super.latitude,
    super.longitude,
  });

  factory AvailableRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AvailableRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableRequestModelToJson(this);
}
