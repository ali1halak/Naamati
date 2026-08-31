import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../bloc/donation_details_cubit.dart';
import '../bloc/donation_details_state.dart';

/// "Mark as delivered" flow — the donor enters the one-time confirmation code
/// the charity presents (QR payload) to confirm the handover.
///
/// The [cubit] is passed explicitly because the sheet lives in the root
/// overlay, above the page's [BlocProvider].
class ConfirmPickupSheet extends StatefulWidget {
  final DonationDetailsCubit cubit;

  const ConfirmPickupSheet({super.key, required this.cubit});

  static Future<void> show(BuildContext context, {required DonationDetailsCubit cubit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmPickupSheet(cubit: cubit),
    );
  }

  @override
  State<ConfirmPickupSheet> createState() => _ConfirmPickupSheetState();
}

class _ConfirmPickupSheetState extends State<ConfirmPickupSheet> {
  final TextEditingController _tokenController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.cubit.confirmPickup(qrToken: _tokenController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<DonationDetailsCubit, DonationDetailsState>(
      bloc: widget.cubit,
      listenWhen:
          (previous, current) =>
              previous.actionInProgress == DonationAction.confirmPickup &&
              current.actionInProgress == null &&
              current.actionErrorMessage == null,
      listener: (context, state) => Navigator.of(context).pop(),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
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
                      color: AppColors.outlineLight,
                      borderRadius: BorderRadius.circular(AppConstants.radiusCircular.r),
                    ),
                  ),
                ),
                SizedBox(height: AppConstants.paddingMD.h),
                Row(
                  children: [
                    const SizedBox(width: 32),
                    Expanded(
                      child: Text(
                        'تأكيد التسليم',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32.r,
                      height: 32.r,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 20.r,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppConstants.paddingSM.h),
                Text(
                  'اطلب من ممثل الجمعية عرض رمز التأكيد الخاص بالطلب ثم أدخله هنا لإتمام التسليم',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: AppConstants.paddingLG.h),

                BlocBuilder<DonationDetailsCubit, DonationDetailsState>(
                  bloc: widget.cubit,
                  buildWhen: (prev, curr) => prev.actionErrorMessage != curr.actionErrorMessage,
                  builder: (context, state) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _tokenController,
                        autofocus: true,
                        maxLength: 64,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 11.sp,
                          letterSpacing: 0.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'رمز التأكيد',
                          prefixIcon: const Icon(Icons.qr_code_2_rounded),
                          counterStyle: AppTextStyles.bodySmall.copyWith(fontSize: 10.sp),
                        ),
                        validator: (value) {
                          final token = value?.trim() ?? '';
                          if (token.isEmpty) return 'رمز التأكيد مطلوب.';
                          if (token.length != 64) {
                            return 'رمز التأكيد يجب أن يتكوّن من 64 حرفاً — تأكد من نسخه كاملاً.';
                          }
                          return null;
                        },
                      ),
                      if (state.actionErrorMessage != null) ...[
                        SizedBox(height: AppConstants.paddingSM.h),
                        Text(
                          state.actionErrorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: AppConstants.paddingLG.h),

                BlocBuilder<DonationDetailsCubit, DonationDetailsState>(
                  bloc: widget.cubit,
                  builder: (context, state) => CustomButton(
                    label: 'تأكيد الاستلام',
                    leadingIcon: const Icon(Icons.check_circle_outline_rounded),
                    onPressed: _submit,
                    isLoading: state.actionInProgress == DonationAction.confirmPickup,
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
