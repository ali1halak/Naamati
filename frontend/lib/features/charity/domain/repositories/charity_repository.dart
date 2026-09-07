import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../donation/domain/entities/donation_request.dart';
import '../../../donation/domain/entities/paginated_donations.dart';
import '../entities/charity_order_audit.dart';
import '../entities/paginated_available_requests.dart';
import '../entities/violation.dart';

/// Charity-side donation contracts (backend: `/api/v1/charity/*`).
abstract class CharityRepository {
  /// One page of open requests this charity is eligible to take
  /// (`GET /charity/requests/available`, paginated 15/page).
  Future<Either<Failure, PaginatedAvailableRequests>> getAvailableRequests({
    int page,
  });

  /// Claim a request (`POST /charity/requests/{id}/accept`).
  Future<Either<Failure, DonationRequest>> acceptRequest(
    int id, {
    required int etaMinutes,
  });

  /// Full detail of one order this charity took (`GET /charity/requests/{id}`).
  Future<Either<Failure, DonationRequest>> getOrderDetails(int id);

  /// This charity's own work queue and history (`GET /charity/requests`) —
  /// same resource shape as the donor's own list.
  Future<Either<Failure, PaginatedDonations>> getMyOrders({int page});

  /// Grouped audit view of one order (تفاصيل الطلب) —
  /// `GET /charity/requests/{id}/details`.
  Future<Either<Failure, CharityOrderAudit>> getOrderAudit(int id);

  /// سجل المخالفات (`GET /charity/violations`, paginated 15/page).
  Future<Either<Failure, PaginatedViolations>> getViolations({int page});

  /// The charity's own half of the handover confirmation
  /// (`POST /charity/requests/{id}/pickup`).
  Future<Either<Failure, DonationRequest>> confirmPickup(int id);

  /// "تأكيد التوزيع" — closes the request (`POST /charity/requests/{id}/complete`).
  Future<Either<Failure, DonationRequest>> confirmDistribution(int id);

  /// Files the beneficiary numbers, now or later
  /// (`POST /charity/requests/{id}/impact`, 201).
  Future<Either<Failure, DonationRequest>> recordImpact(
    int id, {
    required int familiesCount,
    required int individualsCount,
    required String area,
    String? notes,
    DateTime? distributedAt,
  });
}
