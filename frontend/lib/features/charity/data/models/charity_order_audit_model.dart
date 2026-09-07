// Nested model fields are redeclared with their concrete types so
// json_serializable generates the nested fromJson/toJson calls, while still
// being forwarded to the entity constructor.
// ignore_for_file: overridden_fields
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/charity_order_audit.dart';

part 'charity_order_audit_model.g.dart';

@JsonSerializable()
class CharityOrderAuditModel extends CharityOrderAudit {
  @override
  @JsonKey(name: 'order_id')
  final String orderId;

  @override
  final int id;

  @override
  final String status;

  @override
  @JsonKey(name: 'status_label')
  final String statusLabel;

  @override
  final CharityOrderDonorInfoModel donor;

  @override
  final CharityOrderDonationInfoModel donation;

  @override
  final CharityOrderPickupInfoModel pickup;

  @override
  final CharityOrderDistributionInfoModel? distribution;

  @override
  @JsonKey(name: 'cancel_reason')
  final String? cancelReason;

  const CharityOrderAuditModel({
    required this.orderId,
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.donor,
    required this.donation,
    required this.pickup,
    this.distribution,
    this.cancelReason,
  }) : super(
         orderId: orderId,
         id: id,
         status: status,
         statusLabel: statusLabel,
         donor: donor,
         donation: donation,
         pickup: pickup,
         distribution: distribution,
         cancelReason: cancelReason,
       );

  factory CharityOrderAuditModel.fromJson(Map<String, dynamic> json) =>
      _$CharityOrderAuditModelFromJson(json);

  Map<String, dynamic> toJson() => _$CharityOrderAuditModelToJson(this);
}

@JsonSerializable()
class CharityOrderDonorInfoModel extends CharityOrderDonorInfo {
  const CharityOrderDonorInfoModel({super.name, super.phone});

  factory CharityOrderDonorInfoModel.fromJson(Map<String, dynamic> json) =>
      _$CharityOrderDonorInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$CharityOrderDonorInfoModelToJson(this);
}

@JsonSerializable()
class CharityOrderDonationInfoModel extends CharityOrderDonationInfo {
  const CharityOrderDonationInfoModel({
    super.category,
    @JsonKey(name: 'category_icon') super.categoryIcon,
    @JsonKey(name: 'food_condition') super.foodCondition,
    super.quantity,
    super.description,
    @JsonKey(name: 'expiry_date') super.expiryDate,
    @JsonKey(name: 'created_at_iso') super.createdAt,
    @JsonKey(defaultValue: []) super.images,
  });

  factory CharityOrderDonationInfoModel.fromJson(Map<String, dynamic> json) =>
      _$CharityOrderDonationInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$CharityOrderDonationInfoModelToJson(this);
}

@JsonSerializable()
class CharityOrderPickupInfoModel extends CharityOrderPickupInfo {
  const CharityOrderPickupInfoModel({
    @JsonKey(name: 'accepted_at') super.acceptedAt,
    @JsonKey(name: 'actual_pickup_at') super.actualPickupAt,
    super.deadline,
    super.location,
    super.latitude,
    super.longitude,
    super.notes,
    @JsonKey(name: 'eta_minutes') super.etaMinutes,
  });

  factory CharityOrderPickupInfoModel.fromJson(Map<String, dynamic> json) =>
      _$CharityOrderPickupInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$CharityOrderPickupInfoModelToJson(this);
}

@JsonSerializable()
class CharityOrderDistributionInfoModel extends CharityOrderDistributionInfo {
  const CharityOrderDistributionInfoModel({
    @JsonKey(name: 'beneficiary_families') required super.beneficiaryFamilies,
    @JsonKey(name: 'beneficiary_individuals')
    required super.beneficiaryIndividuals,
    @JsonKey(name: 'distribution_zone') required super.distributionZone,
    super.notes,
    @JsonKey(name: 'distributed_at') super.distributedAt,
  });

  factory CharityOrderDistributionInfoModel.fromJson(
    Map<String, dynamic> json,
  ) => _$CharityOrderDistributionInfoModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CharityOrderDistributionInfoModelToJson(this);
}
