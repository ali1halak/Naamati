import 'dart:io';

import 'package:equatable/equatable.dart';

/// Input for publishing a new donation request.
class CreateDonationParams extends Equatable {
  final int foodCategoryId;

  /// Sent explicitly (defaults from the category are applied by the UI).
  final bool needsCooking;

  /// Estimated people count (1–99999) — the stepper guarantees a whole number.
  final int quantity;
  final String? description;

  /// Free-text food name required when the category is "غير ذلك" (other),
  /// so the request never sits under a meaningless generic title.
  final String? customCategory;

  /// Food is edible until this moment (must be in the future).
  final DateTime validUntil;

  /// Pickup deadline — must be in the future and not after [validUntil].
  final DateTime pickupUntil;

  final String pickupAddress;

  /// Optional guidance for the charity driver ("call before arriving").
  final String? pickupNotes;

  /// Up to 4 food photos, sent as multipart parts. On edits these are only
  /// the newly added files; [removedImageIds] names the existing ones to drop.
  final List<File> images;

  /// Edit only: ids of this request's existing photos to delete.
  final List<int> removedImageIds;

  /// Optional map pin — either both coordinates or neither.
  final double? latitude;
  final double? longitude;

  final String contactPhone;

  const CreateDonationParams({
    required this.foodCategoryId,
    required this.needsCooking,
    required this.quantity,
    this.description,
    this.customCategory,
    required this.validUntil,
    required this.pickupUntil,
    required this.pickupAddress,
    this.pickupNotes,
    this.images = const [],
    this.removedImageIds = const [],
    this.latitude,
    this.longitude,
    required this.contactPhone,
  });

  @override
  List<Object?> get props => [
    foodCategoryId,
    needsCooking,
    quantity,
    description,
    customCategory,
    validUntil,
    pickupUntil,
    pickupAddress,
    pickupNotes,
    images,
    removedImageIds,
    latitude,
    longitude,
    contactPhone,
  ];
}
