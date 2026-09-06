import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/donation_status.dart';
import 'donation_status_style.dart';

/// Small colored pill showing a donation's lifecycle status in Arabic.
/// Colors come from [kDonationStatusStyles] so the badges on the cards match
/// the filter chips above the list.
class DonationStatusChip extends StatelessWidget {
  final DonationStatus status;

  const DonationStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = kDonationStatusStyles[status]!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusCircular.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: style.foreground,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            status.labelAr,
            style: AppTextStyles.labelSmall.copyWith(
              color: style.foreground,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
