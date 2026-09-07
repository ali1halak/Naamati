import 'package:equatable/equatable.dart';

import 'rating.dart';

/// Full audit entity of a donation request (what was given, how it travelled,
/// and who it reached).
class DonationAudit extends Equatable {
  final DonationOrderInfo orderInfo;
  final DonationLogisticsDetails logisticsDetails;
  final DonationSocialImpact? socialImpact;
  final Rating? rating;
  final bool canRateCharity;

  const DonationAudit({
    required this.orderInfo,
    required this.logisticsDetails,
    this.socialImpact,
    this.rating,
    required this.canRateCharity,
  });

  @override
  List<Object?> get props => [
    orderInfo,
    logisticsDetails,
    socialImpact,
    rating,
    canRateCharity,
  ];
}

/// Order metadata group (رقم الطلب، نوع الطعام، حالة الطعام، الصلاحية، الوصف).
class DonationOrderInfo extends Equatable {
  final String orderNumber;
  final String? title;
  final String status;
  final String statusLabel;
  final String? foodType;
  final String? foodCondition;
  final String? expiryDate;
  final int? quantity;
  final String? description;

  const DonationOrderInfo({
    required this.orderNumber,
    this.title,
    required this.status,
    required this.statusLabel,
    this.foodType,
    this.foodCondition,
    this.expiryDate,
    this.quantity,
    this.description,
  });

  @override
  List<Object?> get props => [
    orderNumber,
    title,
    status,
    statusLabel,
    foodType,
    foodCondition,
    expiryDate,
    quantity,
    description,
  ];
}

/// Logistics & timeline group (اسم الجمعية، موقع أخذ الطلب، التوقيتات).
class DonationLogisticsDetails extends Equatable {
  final int? charityId;
  final String? charityName;
  final String? pickupAddress;
  final String? submittedAt;
  final String? acceptedAt;
  final String? pickedUpAt;
  final String? completedAt;
  final DateTime? submittedAtIso;
  final DateTime? acceptedAtIso;
  final DateTime? pickedUpAtIso;
  final DateTime? completedAtIso;

  const DonationLogisticsDetails({
    this.charityId,
    this.charityName,
    this.pickupAddress,
    this.submittedAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.completedAt,
    this.submittedAtIso,
    this.acceptedAtIso,
    this.pickedUpAtIso,
    this.completedAtIso,
  });

  @override
  List<Object?> get props => [
    charityId,
    charityName,
    pickupAddress,
    submittedAt,
    acceptedAt,
    pickedUpAt,
    completedAt,
    submittedAtIso,
    acceptedAtIso,
    pickedUpAtIso,
    completedAtIso,
  ];
}

/// Community impact metrics group (العائلات، الأفراد، منطقة التوزيع، الملاحظات).
class DonationSocialImpact extends Equatable {
  final int beneficiaryFamilies;
  final int beneficiaryIndividuals;
  final String distributionZone;
  final String? notes;
  final String? distributedAt;

  const DonationSocialImpact({
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
