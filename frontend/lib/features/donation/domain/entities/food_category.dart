import 'package:equatable/equatable.dart';

/// A food category (e.g. "Cooked/Ready", "Fruits & Vegetables").
class FoodCategory extends Equatable {
  final int id;

  /// Arabic display name — shown in the donor-facing UI.
  final String nameAr;

  /// English name.
  final String nameEn;

  /// Whether food in this category usually needs cooking — used to pre-tick
  /// the "needs cooking" choice in the create form (donor can override).
  final bool defaultNeedsCooking;

  const FoodCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.defaultNeedsCooking,
  });

  @override
  List<Object?> get props => [id, nameAr, nameEn, defaultNeedsCooking];
}
