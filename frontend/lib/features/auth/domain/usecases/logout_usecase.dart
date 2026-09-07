import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call(NoParams params) => repository.logout();
}
