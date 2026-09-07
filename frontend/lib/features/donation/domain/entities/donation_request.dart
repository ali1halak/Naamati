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

  /// Free-text food name set when the donor filed under "غير ذلك" (other) —
  /// also the source of the [title] display field in that case.
  final String? customCategory;

  /// Food is valid until this moment.
  final DateTime? validUntil;

  /// The charity must pick up the food before this moment.
  final DateTime? pickupUntil;

  /// Free-text pickup address.
  final String pickupAddress;

  /// How the charity actually finds the donor ("call 15 minutes before").
  final String? pickupNotes;

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

  /// Food photo URLs (loaded with list/detail responses; empty otherwise).
  final List<String> images;

  /// Backend ids matching [images] one-to-one — the edit form uses them to
  /// target a specific existing photo for removal.
  final List<int> imageIds;

  /// The two-sided handover receipts: the request only reaches `picked_up`
  /// once both are non-null. Null until the request is `accepted`.
  final DateTime? donorConfirmedAt;
  final DateTime? charityConfirmedAt;

  /// Reason entered when the request was cancelled.
  final String? cancelReason;

  /// Who cancelled it — `"donor"` (voluntary) or `"admin"` (moderation).
  /// Only present on cancelled requests; the Arabic wording already arrives
  /// via [statusLabel], so this is for branching, not display.
  final String? cancelledBy;

  final DateTime? createdAt;

  /// Ready-to-render display fields from backend DonationRequestResource:
  final String? statusLabel;
  final String? title;
  final String? categoryIconKey;
  final String? createdAtLabel;

  /// The donor's rating of this donation, once submitted.
  final Rating? rating;

  const DonationRequest({
    required this.id,
    required this.status,
    this.foodCategory,
    required this.needsCooking,
    required this.quantityDesc,
    this.description,
    this.customCategory,
    this.validUntil,
    this.pickupUntil,
    required this.pickupAddress,
    this.pickupNotes,
    this.latitude,
    this.longitude,
    required this.contactPhone,
    this.charity,
    this.etaMinutes,
    this.acceptedAt,
    this.pickedUpAt,
    this.donorConfirmedAt,
    this.charityConfirmedAt,
    this.images = const [],
    this.imageIds = const [],
    this.cancelReason,
    this.cancelledBy,
    this.createdAt,
    this.statusLabel,
    this.title,
    this.categoryIconKey,
    this.createdAtLabel,
    this.rating,
  });

  // ── Convenience delegates ───────────────────────────────────────────────────

  bool get canCancel => status.canCancel;

  /// The donor's confirm button is live only before they pressed it.
  bool get canConfirmPickup => status.canConfirmPickup && donorConfirmedAt == null;

  /// The donor confirmed but the charity has not yet — the request is
  /// deliberately still `accepted` on the wire.
  bool get awaitingCharityConfirmation =>
      status == DonationStatus.accepted &&
      donorConfirmedAt != null &&
      charityConfirmedAt == null;

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
    customCategory,
    validUntil,
    pickupUntil,
    pickupAddress,
    pickupNotes,
    latitude,
    longitude,
    contactPhone,
    charity,
    etaMinutes,
    acceptedAt,
    pickedUpAt,
    donorConfirmedAt,
    charityConfirmedAt,
    images,
    imageIds,
    cancelReason,
    cancelledBy,
    createdAt,
    statusLabel,
    title,
    categoryIconKey,
    createdAtLabel,
    rating,
  ];
}
