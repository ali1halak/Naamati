import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/user.dart';

class RegisterState extends Equatable {
  final BlocStatus status;
  final String? errorMessage;
  final User? user;

  const RegisterState({this.status = BlocStatus.initial, this.errorMessage, this.user});

  bool get isLoading => status == BlocStatus.loading;
  bool get isSuccess => status == BlocStatus.success;
  bool get isFailure => status == BlocStatus.failure;

  static const Object _unset = Object();

  RegisterState copyWith({
    BlocStatus? status,
    Object? errorMessage = _unset,
    Object? user = _unset,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      user: identical(user, _unset) ? this.user : user as User?,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, user];
}
