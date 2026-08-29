import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:typed_data';

import '../../../../core/base/base_state.dart';
import '../../domain/usecases/register_charity_usecase.dart';
import '../../domain/usecases/register_donor_usecase.dart';
import 'register_state.dart';

@injectable
class RegisterCubit extends Cubit<RegisterState> {
  final RegisterDonorUseCase _registerDonorUseCase;
  final RegisterCharityUseCase _registerCharityUseCase;

  RegisterCubit(
    this._registerDonorUseCase,
    this._registerCharityUseCase,
  ) : super(const RegisterState());

  Future<void> registerDonor({
    required String name,
    required String type,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(state.copyWith(status: BlocStatus.loading, errorMessage: null));

    final result = await _registerDonorUseCase(
      RegisterDonorParams(
        name: name,
        type: type,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
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

  Future<void> registerCharity({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required bool hasKitchen,
    required String address,
    required String workStart,
    required String workEnd,
    Uint8List? licenseDocumentBytes,
    String? licenseDocumentName,
  }) async {
    emit(state.copyWith(status: BlocStatus.loading, errorMessage: null));

    final result = await _registerCharityUseCase(
      RegisterCharityParams(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        hasKitchen: hasKitchen,
        address: address,
        workStart: workStart,
        workEnd: workEnd,
        licenseDocumentBytes: licenseDocumentBytes,
        licenseDocumentName: licenseDocumentName,
      ),
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
