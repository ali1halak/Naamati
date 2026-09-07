import 'package:equatable/equatable.dart';

/// One open donation request a charity can claim (backend
/// `CharityOrderResource` — `GET /charity/requests/available`).
///
/// Trimmed to what answers "should we drive out for this?" — the donor's
/// contact details only appear once the charity has actually accepted it.
class AvailableRequest extends Equatable {
  final int id;
  final String? title;
  final String? description;

  /// First photo for the card; [images] carries the full set.
  final String? imageUrl;
  final List<String> images;

  /// Stable key the app maps to its own imagery (see [DonationCard]).
  final String? categoryIcon;
  final String? quantityDesc;

  /// Whether the food needs cooking before it can be distributed.
  final bool needsCooking;

  /// Ready-to-render labels from the backend.
  final String? expiryDate;
  final String? pickupDeadline;
  final String? createdAtLabel;

  /// Raw values so the app can sort or count down without parsing Arabic.
  final DateTime? validUntil;
  final DateTime? pickupUntil;
  final DateTime? createdAt;

  final String? locationZone;
  final String? pickupNotes;
  final double? latitude;
  final double? longitude;

  const AvailableRequest({
    required this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.images = const [],
    this.categoryIcon,
    this.quantityDesc,
    required this.needsCooking,
    this.expiryDate,
    this.pickupDeadline,
    this.createdAtLabel,
    this.validUntil,
    this.pickupUntil,
    this.createdAt,
    this.locationZone,
    this.pickupNotes,
    this.latitude,
    this.longitude,
  });

  String get foodStateLabelAr => needsCooking ? 'يحتاج طهي' : 'جاهز للتوزيع';

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imageUrl,
    images,
    categoryIcon,
    quantityDesc,
    needsCooking,
    expiryDate,
    pickupDeadline,
    createdAtLabel,
    validUntil,
    pickupUntil,
    createdAt,
    locationZone,
    pickupNotes,
    latitude,
    longitude,
  ];
}
