import 'package:equatable/equatable.dart';

/// Input for publishing a new donation request.
class CreateDonationParams extends Equatable {
  final int foodCategoryId;

  /// Sent explicitly (defaults from the category are applied by the UI).
  final bool needsCooking;

  final String quantityDesc;
  final String? description;

  /// Food is edible until this moment (must be in the future).
  final DateTime validUntil;

  /// Pickup deadline — must be in the future and not after [validUntil].
  final DateTime pickupUntil;

  final String pickupAddress;

  /// Optional map pin — either both coordinates or neither.
  final double? latitude;
  final double? longitude;

  final String contactPhone;

  const CreateDonationParams({
    required this.foodCategoryId,
    required this.needsCooking,
    required this.quantityDesc,
    this.description,
    required this.validUntil,
    required this.pickupUntil,
    required this.pickupAddress,
    this.latitude,
    this.longitude,
    required this.contactPhone,
  });

  @override
  List<Object?> get props => [
    foodCategoryId,
    needsCooking,
    quantityDesc,
    description,
    validUntil,
    pickupUntil,
    pickupAddress,
    latitude,
    longitude,
    contactPhone,
  ];
}
