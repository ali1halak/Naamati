import 'package:equatable/equatable.dart';

import '../../../../core/base/base_state.dart';
import '../../domain/entities/my_profile.dart';

/// Which mutation (if any) is currently in flight.
enum ProfileAction { updateFields, updatePhoto, changePassword }

class ProfileState extends Equatable {
  final BlocStatus status;
  final String? errorMessage;

  final MyProfile? profile;

  final ProfileAction? actionInProgress;
  final String? actionErrorMessage;

  /// One-shot success message for snackbars.
  final String? successMessage;

  const ProfileState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.profile,
    this.actionInProgress,
    this.actionErrorMessage,
    this.successMessage,
  });

  bool get isLoading => status == BlocStatus.loading;
  bool get isFailure => status == BlocStatus.failure;
  bool get isSuccess => status == BlocStatus.success;

  static const Object _unset = Object();

  ProfileState copyWith({
    BlocStatus? status,
    Object? errorMessage = _unset,
    Object? profile = _unset,
    Object? actionInProgress = _unset,
    Object? actionErrorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return ProfileState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      profile: identical(profile, _unset)
          ? this.profile
          : profile as MyProfile?,
      actionInProgress: identical(actionInProgress, _unset)
          ? this.actionInProgress
          : actionInProgress as ProfileAction?,
      actionErrorMessage: identical(actionErrorMessage, _unset)
          ? this.actionErrorMessage
          : actionErrorMessage as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    profile,
    actionInProgress,
    actionErrorMessage,
    successMessage,
  ];
}
