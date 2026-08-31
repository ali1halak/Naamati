import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/donation_request.dart';

/// White rounded card listing the donation's key details — reused on the
/// pending screen, the accepted/details screen and terminal states.
class DonationSummaryCard extends StatelessWidget {
  final DonationRequest donation;

  const DonationSummaryCard({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMD.w,
        vertical: AppConstants.paddingMD.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.category_rounded,
            label: 'نوع الطعام',
            value: donation.foodCategory?.nameAr ?? '—',
          ),
          _SummaryRow(
            icon: Icons.local_dining_rounded,
            label: 'الكمية',
            value: donation.quantityDesc,
          ),
          _SummaryRow(
            icon: donation.needsCooking ? Icons.soup_kitchen_rounded : Icons.restaurant_rounded,
            label: 'حالة الطعام',
            value: donation.foodStateLabelAr,
          ),
          _SummaryRow(
            icon: Icons.schedule_rounded,
            label: 'آخر وقت للاستلام',
            value: DateFormatter.formatDateTime(donation.pickupUntil),
            highlight: true,
          ),
          if (donation.description != null && donation.description!.trim().isNotEmpty)
            _SummaryRow(
              icon: Icons.notes_rounded,
              label: 'وصف إضافي',
              value: donation.description!,
            ),
          _SummaryRow(
            icon: Icons.location_on_outlined,
            label: 'عنوان الاستلام',
            value: donation.pickupAddress,
          ),
          _SummaryRow(
            icon: Icons.phone_outlined,
            label: 'رقم التواصل',
            value: donation.contactPhone,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppConstants.paddingSM.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: highlight ? AppColors.primaryContainer : AppColors.surfaceVariantLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 17.r,
              color: highlight ? AppColors.brandGreen : AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(width: AppConstants.paddingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
