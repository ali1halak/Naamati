import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/donation_request.dart';
import 'donation_status_chip.dart';

/// List item for one donation in the "تبرعاتي" tab.
class DonationCard extends StatelessWidget {
  final DonationRequest donation;
  final VoidCallback? onTap;

  const DonationCard({super.key, required this.donation, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
        child: Ink(
          padding: EdgeInsets.all(AppConstants.paddingMD.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10.r,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  donation.needsCooking
                      ? Icons.soup_kitchen_rounded
                      : Icons.restaurant_menu_rounded,
                  size: 22.r,
                  color: AppColors.brandGreen,
                ),
              ),
              SizedBox(width: AppConstants.paddingMD.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donation.foodCategory?.nameAr ?? 'طلب تبرع',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${donation.quantityDesc} · ${DateFormatter.formatDate(donation.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppConstants.paddingSM.w),
              DonationStatusChip(status: donation.status),
            ],
          ),
        ),
      ),
    );
  }
}
