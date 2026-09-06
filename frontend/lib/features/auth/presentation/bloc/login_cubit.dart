import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/usecases/login_usecase.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginCubit(this._loginUseCase) : super(const LoginState());

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: BlocStatus.loading, errorMessage: null));

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(state.copyWith(status: BlocStatus.success, user: user)),
    );
  }
}
