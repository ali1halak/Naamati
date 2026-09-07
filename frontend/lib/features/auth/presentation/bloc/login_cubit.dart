import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../../../core/push/push_notification_service.dart';
import '../../domain/usecases/login_usecase.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;
  final PushNotificationService _pushNotificationService;

  LoginCubit(this._loginUseCase, this._pushNotificationService)
    : super(const LoginState());

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: BlocStatus.loading, errorMessage: null));

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: BlocStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (user) {
        if (isClosed) return;
        emit(state.copyWith(status: BlocStatus.success, user: user));
        // Earlier registration attempts (app startup) ran before we had an
        // auth token and were silently dropped — retry now that we do.
        _pushNotificationService.registerCurrentToken();
      },
    );
  }
}
