import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/food_category.dart';
import '../../domain/params/create_donation_params.dart';
import '../../domain/usecases/create_donation_usecase.dart';
import '../../domain/usecases/get_food_categories_usecase.dart';
import 'create_donation_state.dart';

@injectable
class CreateDonationCubit extends Cubit<CreateDonationState> {
  final GetFoodCategoriesUseCase _getFoodCategoriesUseCase;
  final CreateDonationUseCase _createDonationUseCase;

  CreateDonationCubit(this._getFoodCategoriesUseCase, this._createDonationUseCase)
    : super(const CreateDonationState());

  /// Loads the food-category reference list (idempotent).
  Future<void> loadCategories() async {
    if (state.categoriesStatus == BlocStatus.success) return;

    emit(state.copyWith(categoriesStatus: BlocStatus.loading, categoriesErrorMessage: null));

    final result = await _getFoodCategoriesUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(categoriesStatus: BlocStatus.failure, categoriesErrorMessage: failure.message),
      ),
      (categories) => emit(
        state.copyWith(categoriesStatus: BlocStatus.success, categories: categories),
      ),
    );
  }

  /// Selects a food category and pre-ticks the cooking state from its default.
  void selectCategory(FoodCategory category) {
    emit(
      state.copyWith(
        selectedCategoryId: category.id,
        needsCooking: category.defaultNeedsCooking,
      ),
    );
  }

  /// Donor overrides the cooking state derived from the category.
  void setNeedsCooking(bool value) {
    emit(state.copyWith(needsCooking: value));
  }

  /// Publishes the donation request.
  Future<void> submit(CreateDonationParams params) async {
    emit(state.copyWith(status: BlocStatus.loading, errorMessage: null));

    final result = await _createDonationUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, errorMessage: failure.message)),
      (donation) => emit(state.copyWith(status: BlocStatus.success, createdDonation: donation)),
    );
  }

  /// Returns the form to its pristine state (e.g. when re-entering the page).
  void reset() {
    emit(
      state.copyWith(
        status: BlocStatus.initial,
        errorMessage: null,
        createdDonation: null,
        selectedCategoryId: null,
        needsCooking: false,
      ),
    );
  }
}
