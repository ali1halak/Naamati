import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/base/base_state.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/get_my_profile_usecase.dart';
import '../../domain/usecases/update_profile_photo_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetMyProfileUseCase _getMyProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdateProfilePhotoUseCase _updateProfilePhotoUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  ProfileCubit(
    this._getMyProfileUseCase,
    this._updateProfileUseCase,
    this._updateProfilePhotoUseCase,
    this._changePasswordUseCase,
  ) : super(const ProfileState());

  Future<void> load() async {
    emit(state.copyWith(status: BlocStatus.loading, errorMessage: null));

    final result = await _getMyProfileUseCase(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BlocStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (profile) =>
          emit(state.copyWith(status: BlocStatus.success, profile: profile)),
    );
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    String? type,
    String? address,
    String? workStart,
    String? workEnd,
    bool? hasKitchen,
  }) async {
    emit(
      state.copyWith(
        actionInProgress: ProfileAction.updateFields,
        actionErrorMessage: null,
      ),
    );

    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        name: name,
        phone: phone,
        type: type,
        address: address,
        workStart: workStart,
        workEnd: workEnd,
        hasKitchen: hasKitchen,
      ),
    );

    bool ok = false;
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionInProgress: null,
          actionErrorMessage: failure.message,
        ),
      ),
      (profile) {
        ok = true;
        emit(
          state.copyWith(
            actionInProgress: null,
            profile: profile,
            successMessage: 'تم تحديث الملف الشخصي',
          ),
        );
      },
    );
    return ok;
  }

  Future<bool> updatePhoto(File photo) async {
    emit(
      state.copyWith(
        actionInProgress: ProfileAction.updatePhoto,
        actionErrorMessage: null,
      ),
    );

    final result = await _updateProfilePhotoUseCase(
      UpdateProfilePhotoParams(photo: photo),
    );

    bool ok = false;
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionInProgress: null,
          actionErrorMessage: failure.message,
        ),
      ),
      (profile) {
        ok = true;
        emit(
          state.copyWith(
            actionInProgress: null,
            profile: profile,
            successMessage: 'تم تحديث الصورة',
          ),
        );
      },
    );
    return ok;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(
      state.copyWith(
        actionInProgress: ProfileAction.changePassword,
        actionErrorMessage: null,
      ),
    );

    final result = await _changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );

    bool ok = false;
    result.fold(
      (failure) => emit(
        state.copyWith(
          actionInProgress: null,
          actionErrorMessage: failure.message,
        ),
      ),
      (_) {
        ok = true;
        emit(
          state.copyWith(
            actionInProgress: null,
            successMessage: 'تم تغيير كلمة المرور',
          ),
        );
      },
    );
    return ok;
  }

  void consumeSuccessMessage() => emit(state.copyWith(successMessage: null));

  void clearActionError() => emit(state.copyWith(actionErrorMessage: null));
}
