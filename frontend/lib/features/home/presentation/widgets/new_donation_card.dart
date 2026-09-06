import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Primary CTA card with plus icon, title and subtitle.
///
/// Fills with [ColorScheme.primary] and uses [ColorScheme.onPrimary] for
/// content, so it adapts to both the light (dark-green) and dark (soft-green)
/// palettes. Rounded 20, centered content, subtle shadow.
class NewDonationCard extends StatelessWidget {
  final VoidCallback? onTap;

  const NewDonationCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL.r),
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLG.w,
            vertical: 36.h,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(AppConstants.radiusXL.r),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: 16.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: onPrimary.withValues(alpha: 0.22),
                    width: 1.w,
                  ),
                ),
                child: Icon(Icons.add_rounded, size: 32.r, color: onPrimary),
              ),
              SizedBox(height: 20.h),
              Text(
                'طلب تبرع جديد',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'ساهم في إحداث فرق اليوم بخطوة\nبسيطة',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: onPrimary.withValues(alpha: 0.78),
                  fontSize: 12.sp,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
