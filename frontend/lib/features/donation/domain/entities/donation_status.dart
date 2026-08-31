import 'package:json_annotation/json_annotation.dart';

/// Lifecycle status of a donation request, mirroring the backend
/// `RequestStatus` enum (wire names via [JsonValue]).
enum DonationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('picked_up')
  pickedUp,
  @JsonValue('completed')
  completed,
  @JsonValue('expired')
  expired,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('no_show')
  noShow;

  /// Value sent to / matched from the API.
  String get wireName => switch (this) {
    pending => 'pending',
    accepted => 'accepted',
    pickedUp => 'picked_up',
    completed => 'completed',
    expired => 'expired',
    cancelled => 'cancelled',
    noShow => 'no_show',
  };

  /// Arabic display label.
  String get labelAr => switch (this) {
    pending => 'قيد الانتظار',
    accepted => 'تم القبول',
    pickedUp => 'تم الاستلام',
    completed => 'مكتمل',
    expired => 'منتهي',
    cancelled => 'ملغي',
    noShow => 'لم يتم الحضور',
  };

  /// Terminal statuses can never transition again.
  bool get isTerminal =>
      this == completed || this == expired || this == cancelled || this == noShow;

  /// Active statuses may still change (accept, pickup, expire…).
  bool get isActive => !isTerminal;

  /// Backend allows the donor to cancel only from these statuses.
  bool get canCancel => this == pending || this == accepted;

  /// The donor can confirm the handover only while accepted.
  bool get canConfirmPickup => this == accepted;

  /// Rating is allowed from picked_up onward, once per donation.
  bool get canRate => this == pickedUp || this == completed;
}
