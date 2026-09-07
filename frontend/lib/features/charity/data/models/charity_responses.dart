import 'package:json_annotation/json_annotation.dart';

import '../../../donation/data/models/donation_request_model.dart';
import '../../../donation/data/models/donation_responses.dart';
import 'available_request_model.dart';

part 'charity_responses.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// API envelope models for the charity-side donation endpoints.
// Every backend response is `{ success, data, message }`.
//
// The mutation endpoints (accept / pickup / complete / impact) return the
// same `DonationRequestResource` shape the donor side gets, so they reuse
// [DonationResponseModel] and [DonationRequestModel] from the donation
// feature rather than redeclaring an identical envelope.
// ─────────────────────────────────────────────────────────────────────────────

/// Envelope for `GET /charity/requests/available` — Laravel paginated
/// collection of [AvailableRequestModel].
@JsonSerializable()
class AvailableRequestListResponseModel {
  final bool success;
  final AvailableRequestListDataModel data;
  final String? message;

  const AvailableRequestListResponseModel({
    required this.success,
    required this.data,
    this.message,
  });

  factory AvailableRequestListResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => _$AvailableRequestListResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AvailableRequestListResponseModelToJson(this);
}

/// Paginated payload: `{ data: [...rows], links: {...}, meta: {...} }`.
@JsonSerializable()
class AvailableRequestListDataModel {
  final List<AvailableRequestModel> data;
  final DonationPaginationMetaModel? meta;

  const AvailableRequestListDataModel({required this.data, this.meta});

  factory AvailableRequestListDataModel.fromJson(Map<String, dynamic> json) =>
      _$AvailableRequestListDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableRequestListDataModelToJson(this);
}

// Re-exported so charity-feature callers only need to import this file for
// the mutation envelope, without reaching into the donation feature.
typedef CharityOrderResponseModel = DonationResponseModel;
typedef CharityOrderModel = DonationRequestModel;
