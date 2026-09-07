import 'package:json_annotation/json_annotation.dart';

import 'charity_order_audit_model.dart';

part 'charity_order_audit_response.g.dart';

/// Envelope for `GET /charity/requests/{id}/details`.
@JsonSerializable()
class CharityOrderAuditResponseModel {
  final bool success;
  final CharityOrderAuditModel data;
  final String? message;

  const CharityOrderAuditResponseModel({
    required this.success,
    required this.data,
    this.message,
  });

  factory CharityOrderAuditResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CharityOrderAuditResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CharityOrderAuditResponseModelToJson(this);
}
