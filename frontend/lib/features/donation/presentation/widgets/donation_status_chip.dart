import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/donation_status.dart';

/// Small colored pill showing a donation's lifecycle status in Arabic.
class DonationStatusChip extends StatelessWidget {
  final DonationStatus status;

  const DonationStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (status) {
      DonationStatus.pending => (AppColors.textSecondaryLight, AppColors.surfaceVariantLight),
      DonationStatus.accepted => (AppColors.success, AppColors.successContainer),
      DonationStatus.pickedUp => (AppColors.brandGreen, AppColors.primaryContainer),
      DonationStatus.completed => (Colors.white, AppColors.brandGreen),
      DonationStatus.expired => (AppColors.textSecondaryLight, AppColors.surfaceVariantLight),
      DonationStatus.cancelled => (AppColors.error, AppColors.errorContainer),
      DonationStatus.noShow => (AppColors.error, AppColors.errorContainer),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppConstants.radiusCircular.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(color: foreground, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(
            status.labelAr,
            style: AppTextStyles.labelSmall.copyWith(
              color: foreground,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
