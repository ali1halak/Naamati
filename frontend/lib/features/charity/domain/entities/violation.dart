import 'package:equatable/equatable.dart';

/// One row on the charity's own "سجل المخالفات" (compliance record) —
/// read-only, filed by an admin (backend: `ViolationResource`).
class Violation extends Equatable {
  final int id;
  final String reference;
  final String type;
  final String title;
  final String severity;
  final String severityLabel;
  final String adminNote;
  final int? donationRequestId;
  final String date;
  final DateTime? createdAt;

  const Violation({
    required this.id,
    required this.reference,
    required this.type,
    required this.title,
    required this.severity,
    required this.severityLabel,
    required this.adminNote,
    this.donationRequestId,
    required this.date,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    reference,
    type,
    title,
    severity,
    severityLabel,
    adminNote,
    donationRequestId,
    date,
    createdAt,
  ];
}

/// How close the account is to an automatic suspension — shown alongside
/// the list so a violation is never a surprise.
class ComplianceInfo extends Equatable {
  final int totalWeight;
  final int suspensionThreshold;
  final String accountStatus;

  const ComplianceInfo({
    required this.totalWeight,
    required this.suspensionThreshold,
    required this.accountStatus,
  });

  @override
  List<Object?> get props => [totalWeight, suspensionThreshold, accountStatus];
}

/// One page of the violations feed plus pagination and compliance summary.
class PaginatedViolations extends Equatable {
  final List<Violation> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final ComplianceInfo? compliance;

  const PaginatedViolations({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.compliance,
  });

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [items, currentPage, lastPage, total, compliance];
}
