import 'package:equatable/equatable.dart';

/// Grouped audit view of one order the charity handled (تفاصيل الطلب) —
/// backend: `CharityOrderAuditResource`. Mirrors the donor-side
/// `DonationAudit`'s section grouping, but from the charity's point of view
/// (donor contact instead of charity contact, no rating section).
class CharityOrderAudit extends Equatable {
  final String orderId;
  final int id;
  final String status;
  final String statusLabel;
  final CharityOrderDonorInfo donor;
  final CharityOrderDonationInfo donation;
  final CharityOrderPickupInfo pickup;
  final CharityOrderDistributionInfo? distribution;
  final String? cancelReason;

  const CharityOrderAudit({
    required this.orderId,
    required this.id,
    required this.status,
    required this.statusLabel,
    required this.donor,
    required this.donation,
    required this.pickup,
    this.distribution,
    this.cancelReason,
  });

  @override
  List<Object?> get props => [
    orderId,
    id,
    status,
    statusLabel,
    donor,
    donation,
    pickup,
    distribution,
    cancelReason,
  ];
}

class CharityOrderDonorInfo extends Equatable {
  final String? name;
  final String? phone;

  const CharityOrderDonorInfo({this.name, this.phone});

  @override
  List<Object?> get props => [name, phone];
}

class CharityOrderDonationInfo extends Equatable {
  final String? category;
  final String? categoryIcon;
  final String? foodCondition;
  final int? quantity;
  final String? description;
  final String? expiryDate;
  final String? createdAt;
  final List<String> images;

  const CharityOrderDonationInfo({
    this.category,
    this.categoryIcon,
    this.foodCondition,
    this.quantity,
    this.description,
    this.expiryDate,
    this.createdAt,
    this.images = const [],
  });

  @override
  List<Object?> get props => [
    category,
    categoryIcon,
    foodCondition,
    quantity,
    description,
    expiryDate,
    createdAt,
    images,
  ];
}

class CharityOrderPickupInfo extends Equatable {
  final String? acceptedAt;
  final String? actualPickupAt;
  final String? deadline;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final int? etaMinutes;

  const CharityOrderPickupInfo({
    this.acceptedAt,
    this.actualPickupAt,
    this.deadline,
    this.location,
    this.latitude,
    this.longitude,
    this.notes,
    this.etaMinutes,
  });

  @override
  List<Object?> get props => [
    acceptedAt,
    actualPickupAt,
    deadline,
    location,
    latitude,
    longitude,
    notes,
    etaMinutes,
  ];
}

class CharityOrderDistributionInfo extends Equatable {
  final int beneficiaryFamilies;
  final int beneficiaryIndividuals;
  final String distributionZone;
  final String? notes;
  final String? distributedAt;

  const CharityOrderDistributionInfo({
    required this.beneficiaryFamilies,
    required this.beneficiaryIndividuals,
    required this.distributionZone,
    this.notes,
    this.distributedAt,
  });

  @override
  List<Object?> get props => [
    beneficiaryFamilies,
    beneficiaryIndividuals,
    distributionZone,
    notes,
    distributedAt,
  ];
}
