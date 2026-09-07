import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/violation.dart';

part 'violation_model.g.dart';

@JsonSerializable()
class ViolationModel extends Violation {
  const ViolationModel({
    required super.id,
    required super.reference,
    required super.type,
    required super.title,
    required super.severity,
    @JsonKey(name: 'severity_label') required super.severityLabel,
    @JsonKey(name: 'admin_note') required super.adminNote,
    @JsonKey(name: 'donation_request_id') super.donationRequestId,
    required super.date,
    @JsonKey(name: 'created_at') super.createdAt,
  });

  factory ViolationModel.fromJson(Map<String, dynamic> json) =>
      _$ViolationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ViolationModelToJson(this);
}

@JsonSerializable()
class ComplianceInfoModel extends ComplianceInfo {
  const ComplianceInfoModel({
    @JsonKey(name: 'total_weight') required super.totalWeight,
    @JsonKey(name: 'suspension_threshold') required super.suspensionThreshold,
    @JsonKey(name: 'account_status') required super.accountStatus,
  });

  factory ComplianceInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ComplianceInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComplianceInfoModelToJson(this);
}
