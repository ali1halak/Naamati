import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/violation.dart';

/// One card on the charity's "سجل المخالفات" screen.
class ViolationCard extends StatelessWidget {
  final Violation violation;

  const ViolationCard({super.key, required this.violation});

  ({Color background, Color foreground, IconData icon}) get _severityStyle {
    switch (violation.severity) {
      case 'high':
        return (
          background: AppColors.errorContainer,
          foreground: AppColors.error,
          icon: Icons.error_outline_rounded,
        );
      case 'medium':
        return (
          background: AppColors.warningContainer,
          foreground: AppColors.secondaryDark,
          icon: Icons.warning_amber_rounded,
        );
      default:
        return (
          background: AppColors.secondaryContainer,
          foreground: AppColors.secondaryDark,
          icon: Icons.info_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = _severityStyle;

    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMD.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: style.background,
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, size: 20.r, color: style.foreground),
          ),
          SizedBox(width: AppConstants.paddingMD.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        violation.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      violation.date,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'ملاحظات الإدارة:',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  violation.adminNote,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.sp,
                    height: 1.5,
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
