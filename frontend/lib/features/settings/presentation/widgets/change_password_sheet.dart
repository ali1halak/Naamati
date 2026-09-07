import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../profile/presentation/bloc/profile_cubit.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

/// "تغيير كلمة المرور" bottom sheet — same structural pattern as
/// `AcceptRequestSheet`/the donation-audit rating sheet: a `Form` inside a
/// rounded-top sheet, submitting through the cubit already provided above it.
class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  static Future<void> show(BuildContext context, ProfileCubit cubit) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const ChangePasswordSheet()),
    );
  }

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await context.read<ProfileCubit>().changePassword(
      currentPassword: _currentController.text,
      password: _newController.text,
      passwordConfirmation: _confirmController.text,
    );

    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppConstants.radiusXL.r),
              topRight: Radius.circular(AppConstants.radiusXL.r),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            AppConstants.paddingLG.w,
            AppConstants.paddingMD.h,
            AppConstants.paddingLG.w,
            AppConstants.paddingLG.h,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusCircular.r,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppConstants.paddingMD.h),
                Text(
                  'تغيير كلمة المرور',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18.sp,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: AppConstants.paddingLG.h),
                CustomTextField(
                  label: 'كلمة المرور الحالية',
                  controller: _currentController,
                  obscureText: true,
                  isRequired: true,
                  validator: requiredFieldValidator(
                    fieldName: 'كلمة المرور الحالية',
                  ),
                  prefixIcon: Icons.lock_outline,
                ),
                SizedBox(height: AppConstants.paddingMD.h),
                CustomTextField(
                  label: 'كلمة المرور الجديدة',
                  controller: _newController,
                  obscureText: true,
                  isRequired: true,
                  validator: passwordValidator,
                  prefixIcon: Icons.lock_reset_outlined,
                ),
                SizedBox(height: AppConstants.paddingMD.h),
                CustomTextField(
                  label: 'تأكيد كلمة المرور الجديدة',
                  controller: _confirmController,
                  obscureText: true,
                  isRequired: true,
                  validator: confirmPasswordValidator(
                    () => _newController.text,
                  ),
                  prefixIcon: Icons.lock_reset_outlined,
                ),
                SizedBox(height: AppConstants.paddingLG.h),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    if (state.actionErrorMessage == null) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: AppConstants.paddingSM.h,
                      ),
                      child: Text(
                        state.actionErrorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    );
                  },
                ),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) => CustomButton(
                    label: 'تغيير كلمة المرور',
                    onPressed: _submit,
                    isLoading:
                        state.actionInProgress == ProfileAction.changePassword,
                  ),
                ),
                SizedBox(height: AppConstants.paddingSM.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
