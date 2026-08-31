import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/food_category.dart';
import '../repositories/donation_repository.dart';

@lazySingleton
class GetFoodCategoriesUseCase implements UseCase<List<FoodCategory>, NoParams> {
  final DonationRepository repository;

  GetFoodCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FoodCategory>>> call(NoParams params) {
    return repository.getFoodCategories();
  }
}
