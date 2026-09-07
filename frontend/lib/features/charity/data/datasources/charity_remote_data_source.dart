import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../donation/data/models/donation_responses.dart';
import '../models/charity_order_audit_response.dart';
import '../models/charity_responses.dart';
import '../models/violation_responses.dart';

part 'charity_remote_data_source.g.dart';

/// Charity-side donation API (`/api/v1/charity/*`).
@RestApi()
abstract class CharityRemoteDataSource {
  @factoryMethod
  factory CharityRemoteDataSource(Dio dio) = _CharityRemoteDataSource;

  /// Open requests this charity is eligible to take.
  @GET('/charity/requests/available')
  Future<AvailableRequestListResponseModel> getAvailableRequests({
    @Query('page') int? page,
  });

  /// Claim a request, giving the donor an ETA in minutes.
  @POST('/charity/requests/{id}/accept')
  Future<DonationResponseModel> acceptRequest(
    @Path('id') int id, {
    @Field('eta_minutes') required int etaMinutes,
  });

  @GET('/charity/requests/{id}')
  Future<DonationResponseModel> getOrderDetails(@Path('id') int id);

  /// This charity's own work queue and history — same resource shape as the
  /// donor's own list (`DonationRequestResource`), just scoped server-side.
  @GET('/charity/requests')
  Future<DonationListResponseModel> getMyOrders({
    @Query('status') String? status,
    @Query('page') int? page,
  });

  /// Grouped audit view of one order this charity handled (تفاصيل الطلب) —
  /// distinct from [getOrderDetails]'s flat shape, which the active-tracking
  /// screen uses instead.
  @GET('/charity/requests/{id}/details')
  Future<CharityOrderAuditResponseModel> getOrderAudit(@Path('id') int id);

  /// سجل المخالفات — read-only compliance record.
  @GET('/charity/violations')
  Future<ViolationListResponseModel> getViolations({@Query('page') int? page});

  /// The charity's own half of the two-sided handover confirmation.
  @POST('/charity/requests/{id}/pickup')
  Future<DonationResponseModel> confirmPickup(@Path('id') int id);

  /// "تأكيد التوزيع" — the food has been handed out; closes the request.
  @POST('/charity/requests/{id}/complete')
  Future<DonationResponseModel> confirmDistribution(@Path('id') int id);

  /// "حفظ البيانات" — how many people the food reached.
  @POST('/charity/requests/{id}/impact')
  Future<DonationResponseModel> recordImpact(
    @Path('id') int id, {
    @Field('families_count') required int familiesCount,
    @Field('individuals_count') required int individualsCount,
    @Field('area') required String area,
    @Field('notes') String? notes,
    @Field('distributed_at') String? distributedAt,
  });
}
