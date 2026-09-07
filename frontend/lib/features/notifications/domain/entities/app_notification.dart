import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

/// Mirrors `App\Enums\NotificationType` on the backend (wire names via
/// [JsonValue]).
enum NotificationKind {
  @JsonValue('request_accepted')
  requestAccepted,
  @JsonValue('handover_confirmed')
  handoverConfirmed,
  @JsonValue('request_cancelled')
  requestCancelled,
  @JsonValue('new_request_available')
  newRequestAvailable,
  @JsonValue('awaiting_other_confirmation')
  awaitingOtherConfirmation,
  @JsonValue('distribution_completed')
  distributionCompleted,
  @JsonValue('request_expired')
  requestExpired,
  @JsonValue('request_no_show')
  requestNoShow,
  @JsonValue('new_rating')
  newRating,
  @JsonValue('charity_approved')
  charityApproved,
  @JsonValue('charity_suspended')
  charitySuspended,
  @JsonValue('unknown')
  unknown,
}

/// One row from the signed-in account's own notification feed
/// (`GET /notifications`) — donor and charity share the same shape, scoped
/// server-side to whichever account is asking.
///
/// [payload] is denormalised on the backend (names at the time of the
/// event), so the display text is built from it rather than by re-fetching
/// the donation.
class AppNotification extends Equatable {
  final int id;
  final NotificationKind kind;
  final Map<String, dynamic> payload;
  final bool isRead;
  final int? donationRequestId;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.payload,
    required this.isRead,
    this.donationRequestId,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    kind,
    payload,
    isRead,
    donationRequestId,
    createdAt,
  ];
}
