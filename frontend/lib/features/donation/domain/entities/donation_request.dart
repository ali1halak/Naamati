import 'package:equatable/equatable.dart';

import 'charity_profile.dart';
import 'donation_status.dart';
import 'food_category.dart';
import 'rating.dart';

/// A donor's surplus-food donation request.
class DonationRequest extends Equatable {
  final int id;
  final DonationStatus status;

  /// Category of the donated food (may be null if the API omitted it).
  final FoodCategory? foodCategory;

  /// Whether the food needs cooking before consumption.
  final bool needsCooking;

  /// Free-text quantity description (e.g. "وجبات تكفي 10 أشخاص").
  final String quantityDesc;

  /// Optional extra description.
  final String? description;

  /// Food is valid until this moment.
  final DateTime? validUntil;

  /// The charity must pick up the food before this moment.
  final DateTime? pickupUntil;

  /// Free-text pickup address.
  final String pickupAddress;

  /// Optional map pin (null when the donor only typed an address).
  final double? latitude;
  final double? longitude;

  /// Phone the charity uses to coordinate the pickup.
  final String contactPhone;

  /// Assigned charity — present only once a charity has accepted.
  final CharityProfile? charity;

  /// ETA (minutes) the charity gave when accepting.
  final int? etaMinutes;

  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;

  /// Reason entered when the donor cancelled.
  final String? cancelReason;

  final DateTime? createdAt;

  /// The donor's rating of this donation, once submitted.
  final Rating? rating;

  const DonationRequest({
    required this.id,
    required this.status,
    this.foodCategory,
    required this.needsCooking,
    required this.quantityDesc,
    this.description,
    this.validUntil,
    this.pickupUntil,
    required this.pickupAddress,
    this.latitude,
    this.longitude,
    required this.contactPhone,
    this.charity,
    this.etaMinutes,
    this.acceptedAt,
    this.pickedUpAt,
    this.cancelReason,
    this.createdAt,
    this.rating,
  });

  // ── Convenience delegates ───────────────────────────────────────────────────

  bool get canCancel => status.canCancel;

  bool get canConfirmPickup => status.canConfirmPickup;

  /// Rating is allowed once the food was picked up and not yet rated.
  bool get canRate => status.canRate && rating == null;

  String get foodStateLabelAr => needsCooking ? 'يحتاج طهي' : 'جاهز للأكل';

  @override
  List<Object?> get props => [
    id,
    status,
    foodCategory,
    needsCooking,
    quantityDesc,
    description,
    validUntil,
    pickupUntil,
    pickupAddress,
    latitude,
    longitude,
    contactPhone,
    charity,
    etaMinutes,
    acceptedAt,
    pickedUpAt,
    cancelReason,
    createdAt,
    rating,
  ];
}
