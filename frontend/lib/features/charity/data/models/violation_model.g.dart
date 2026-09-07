// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'violation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViolationModel _$ViolationModelFromJson(Map<String, dynamic> json) =>
    ViolationModel(
      id: (json['id'] as num).toInt(),
      reference: json['reference'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      severity: json['severity'] as String,
      severityLabel: json['severity_label'] as String,
      adminNote: json['admin_note'] as String,
      donationRequestId: (json['donation_request_id'] as num?)?.toInt(),
      date: json['date'] as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ViolationModelToJson(ViolationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'type': instance.type,
      'title': instance.title,
      'severity': instance.severity,
      'severity_label': instance.severityLabel,
      'admin_note': instance.adminNote,
      'donation_request_id': instance.donationRequestId,
      'date': instance.date,
      'created_at': instance.createdAt?.toIso8601String(),
    };

ComplianceInfoModel _$ComplianceInfoModelFromJson(Map<String, dynamic> json) =>
    ComplianceInfoModel(
      totalWeight: (json['total_weight'] as num).toInt(),
      suspensionThreshold: (json['suspension_threshold'] as num).toInt(),
      accountStatus: json['account_status'] as String,
    );

Map<String, dynamic> _$ComplianceInfoModelToJson(
  ComplianceInfoModel instance,
) => <String, dynamic>{
  'total_weight': instance.totalWeight,
  'suspension_threshold': instance.suspensionThreshold,
  'account_status': instance.accountStatus,
};
