import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/charity_profile.dart';
import '../bloc/donation_details_cubit.dart';
import '../bloc/donation_details_state.dart';

/// Charity rating modal (Screen 5) — bottom sheet with 5 stars and an
/// optional comment, shown right after the handover is confirmed.
///
/// The [cubit] is passed explicitly because the sheet lives in the root
/// overlay, above the page's [BlocProvider].
class CharityRatingSheet extends StatefulWidget {
  final DonationDetailsCubit cubit;
  final CharityProfile charity;

  const CharityRatingSheet({super.key, required this.cubit, required this.charity});

  static Future<void> show(
    BuildContext context, {
    required DonationDetailsCubit cubit,
    required CharityProfile charity,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CharityRatingSheet(cubit: cubit, charity: charity),
    );
  }

  @override
  State<CharityRatingSheet> createState() => _CharityRatingSheetState();
}

class _CharityRatingSheetState extends State<CharityRatingSheet> {
  int _stars = 0;
  bool _starsTouched = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _starsTouched = true);
    if (_stars < 1) return;

    widget.cubit.rateDonation(stars: _stars, comment: _commentController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<DonationDetailsCubit, DonationDetailsState>(
      bloc: widget.cubit,
      listenWhen:
          (previous, current) =>
              previous.actionInProgress == DonationAction.rate &&
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle.
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
                      'قيّم تبرعك مع الجمعية',
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
                'كيف كانت تجربتك مع ${widget.charity.name}؟',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
              ),
              SizedBox(height: AppConstants.paddingLG.h),

              // Stars.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final filled = index < _stars;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _stars = index + 1;
                      _starsTouched = true;
                    }),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Icon(
                        filled ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 44.r,
                        color: AppColors.warning,
                      ),
                    ),
                  );
                }),
              ),
              if (_starsTouched && _stars < 1)
                Padding(
                  padding: EdgeInsets.only(top: AppConstants.paddingSM.h),
                  child: Text(
                    'يرجى اختيار عدد النجوم',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                  ),
                ),
              SizedBox(height: AppConstants.paddingLG.h),

              // Comment + inline action error.
              BlocBuilder<DonationDetailsCubit, DonationDetailsState>(
                bloc: widget.cubit,
                buildWhen: (prev, curr) => prev.actionErrorMessage != curr.actionErrorMessage,
                builder: (context, state) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _commentController,
                      maxLines: 3,
                      maxLength: 500,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'شاركنا تجربتك مع الجمعية (اختياري)',
                      ),
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
                  label: 'إرسال التقييم',
                  onPressed: _submit,
                  isLoading: state.actionInProgress == DonationAction.rate,
                ),
              ),
              SizedBox(height: AppConstants.paddingSM.h),
            ],
          ),
        ),
      ),
    );
  }
}
