import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';
import 'custom_button.dart';

/// A reusable error display widget.
///
/// Shows a [message] and an optional [onRetry] callback button.
/// Use it as the body of a [Scaffold] or inside any scroll view.
class AppErrorWidget extends StatelessWidget {
  /// Human-readable description of the error.
  final String message;

  /// If provided, renders a "Try again" button that calls this callback.
  final VoidCallback? onRetry;

  /// Optional icon to display above the message (defaults to error_outline).
  final IconData icon;

  /// Optional custom retry button label.
  final String retryLabel;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.retryLabel = 'Try again',
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
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36.r, color: AppColors.error),
            ),
            SizedBox(height: AppConstants.paddingLG.h),
            Text(
              'Something went wrong',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppConstants.paddingSM.h),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppConstants.paddingXL.h),
              CustomButton(label: retryLabel, onPressed: onRetry, width: 160.w),
            ],
          ],
        ),
      ),
    );
  }
}
