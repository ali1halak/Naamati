import 'package:equatable/equatable.dart';

/// A food category (e.g. "Cooked/Ready", "Fruits & Vegetables").
class FoodCategory extends Equatable {
  final int id;

  /// Arabic display name — shown in the donor-facing UI.
  final String nameAr;

  /// English name.
  final String nameEn;

  /// Stable key the app maps to its own imagery, e.g. `cooked_ready`,
  /// `other`. `other` means the donor must name the food themselves.
  final String icon;

  /// Whether food in this category usually needs cooking — used to pre-tick
  /// the "needs cooking" choice in the create form (donor can override).
  final bool defaultNeedsCooking;

  /// Whether a free-text food name is required when this category is picked.
  bool get requiresCustomName => icon == 'other';

  const FoodCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.icon = 'other',
    required this.defaultNeedsCooking,
  });

  @override
  List<Object?> get props => [id, nameAr, nameEn, icon, defaultNeedsCooking];
}
