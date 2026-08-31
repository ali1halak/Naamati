import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/donation_request.dart';
import '../../domain/entities/food_category.dart';

/// State of the "Create Donation Request" form.
///
/// [categoriesStatus]/[categoriesErrorMessage] track loading the food-category
/// reference list; [status]/[errorMessage] track the submit action itself.
class CreateDonationState extends Equatable {
  final BlocStatus categoriesStatus;
  final String? categoriesErrorMessage;
  final List<FoodCategory> categories;

  /// Currently chosen food category (null = not chosen yet).
  final int? selectedCategoryId;

  /// Food-state choice; pre-ticked from the category default when the
  /// category changes, overridable by the donor.
  final bool needsCooking;

  final BlocStatus status;
  final String? errorMessage;

  /// The created donation (present after a successful submit).
  final DonationRequest? createdDonation;

  const CreateDonationState({
    this.categoriesStatus = BlocStatus.initial,
    this.categoriesErrorMessage,
    this.categories = const [],
    this.selectedCategoryId,
    this.needsCooking = false,
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.createdDonation,
  });

  FoodCategory? get selectedCategory => categories.where((c) => c.id == selectedCategoryId).firstOrNull;

  /// Sentinel that lets [copyWith] distinguish "not provided" from "null".
  static const Object _unset = Object();

  CreateDonationState copyWith({
    BlocStatus? categoriesStatus,
    Object? categoriesErrorMessage = _unset,
    List<FoodCategory>? categories,
    Object? selectedCategoryId = _unset,
    bool? needsCooking,
    BlocStatus? status,
    Object? errorMessage = _unset,
    Object? createdDonation = _unset,
  }) {
    return CreateDonationState(
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      categoriesErrorMessage: identical(categoriesErrorMessage, _unset)
          ? this.categoriesErrorMessage
          : categoriesErrorMessage as String?,
      categories: categories ?? this.categories,
      selectedCategoryId: identical(selectedCategoryId, _unset)
          ? this.selectedCategoryId
          : selectedCategoryId as int?,
      needsCooking: needsCooking ?? this.needsCooking,
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      createdDonation: identical(createdDonation, _unset)
          ? this.createdDonation
          : createdDonation as DonationRequest?,
    );
  }

  @override
  List<Object?> get props => [
    categoriesStatus,
    categoriesErrorMessage,
    categories,
    selectedCategoryId,
    needsCooking,
    status,
    errorMessage,
    createdDonation,
  ];
}
