import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

/// A reusable empty-state placeholder widget.
///
/// Displays an [icon], a [title], an optional [subtitle], and an optional
/// [action] button — covering the most common empty-state patterns.
class EmptyStateWidget extends StatelessWidget {
  /// Large icon displayed at the top.
  final IconData icon;

  /// Primary message (e.g. "No results found").
  final String title;

  /// Secondary explanatory text (optional).
  final String? subtitle;

  /// Optional call-to-action button.
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingXL.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.r,
              height: 88.r,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44.r, color: AppColors.primary),
            ),
            SizedBox(height: AppConstants.paddingLG.h),
            Text(
              title,
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppConstants.paddingSM.h),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: AppConstants.paddingXL.h),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
