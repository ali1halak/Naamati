import 'package:json_annotation/json_annotation.dart';

import 'notification_model.dart';

part 'notification_responses.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// API envelope models for the notification endpoints.
// Every backend response is `{ success, data, message }`.
// ─────────────────────────────────────────────────────────────────────────────

/// Envelope for `GET /notifications` — Laravel paginated collection.
@JsonSerializable()
class NotificationListResponseModel {
  final bool success;
  final NotificationListDataModel data;
  final String? message;

  const NotificationListResponseModel({
    required this.success,
    required this.data,
    this.message,
  });

  factory NotificationListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationListResponseModelToJson(this);
}

/// Paginated payload: `{ data: [...rows], links: {...}, meta: {...} }`.
@JsonSerializable()
class NotificationListDataModel {
  final List<NotificationModel> data;
  final NotificationPaginationMetaModel? meta;

  const NotificationListDataModel({required this.data, this.meta});

  factory NotificationListDataModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationListDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationListDataModelToJson(this);
}

@JsonSerializable()
class NotificationPaginationMetaModel {
  @JsonKey(name: 'current_page')
  final int? currentPage;

  @JsonKey(name: 'last_page')
  final int? lastPage;

  @JsonKey(name: 'per_page')
  final int? perPage;

  final int? total;

  const NotificationPaginationMetaModel({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory NotificationPaginationMetaModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationPaginationMetaModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NotificationPaginationMetaModelToJson(this);
}

/// Envelope for `POST /notifications/{id}/read` (data = the updated row).
@JsonSerializable()
class NotificationResponseModel {
  final bool success;
  final NotificationModel data;
  final String? message;

  const NotificationResponseModel({
    required this.success,
    required this.data,
    this.message,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationResponseModelToJson(this);
}
