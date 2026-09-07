import 'package:json_annotation/json_annotation.dart';

import 'violation_model.dart';

part 'violation_responses.g.dart';

/// Envelope for `GET /charity/violations` — Laravel paginated collection plus
/// a `compliance` summary block merged onto the same payload.
@JsonSerializable()
class ViolationListResponseModel {
  final bool success;
  final ViolationListDataModel data;
  final String? message;

  const ViolationListResponseModel({
    required this.success,
    required this.data,
    this.message,
  });

  factory ViolationListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ViolationListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ViolationListResponseModelToJson(this);
}

@JsonSerializable()
class ViolationListDataModel {
  final List<ViolationModel> data;
  final ViolationPaginationMetaModel? meta;
  final ComplianceInfoModel? compliance;

  const ViolationListDataModel({
    required this.data,
    this.meta,
    this.compliance,
  });

  factory ViolationListDataModel.fromJson(Map<String, dynamic> json) =>
      _$ViolationListDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$ViolationListDataModelToJson(this);
}

@JsonSerializable()
class ViolationPaginationMetaModel {
  @JsonKey(name: 'current_page')
  final int? currentPage;

  @JsonKey(name: 'last_page')
  final int? lastPage;

  @JsonKey(name: 'per_page')
  final int? perPage;

  final int? total;

  const ViolationPaginationMetaModel({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory ViolationPaginationMetaModel.fromJson(Map<String, dynamic> json) =>
      _$ViolationPaginationMetaModelFromJson(json);

  Map<String, dynamic> toJson() => _$ViolationPaginationMetaModelToJson(this);
}
