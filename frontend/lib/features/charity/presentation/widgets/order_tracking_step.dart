import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

/// Visual state of one step on the order-tracking timeline.
enum OrderStepStatus { done, current, upcoming }

/// One row of the "متابعة الطلب" vertical timeline: a status dot connected
/// to the next step by a line, a title/description, and an optional action
/// button (shown only for the [OrderStepStatus.current] step).
class OrderTrackingStep extends StatelessWidget {
  final OrderStepStatus status;
  final String title;
  final String description;

  /// Button label for the current step (e.g. "تأكيد الأخذ").
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  /// Hides the connecting line below the last step.
  final bool isLast;

  const OrderTrackingStep({
    super.key,
    required this.status,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = status == OrderStepStatus.done;
    final isCurrent = status == OrderStepStatus.current;

    final dotColor = isDone || isCurrent
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: 0.4);
    final textColor = status == OrderStepStatus.upcoming
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: isDone
                      ? colorScheme.primary
                      : (isCurrent
                            ? colorScheme.surface
                            : colorScheme.surfaceContainerHighest),
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: colorScheme.primary, width: 2.w)
                      : null,
                ),
                child: isDone
                    ? Icon(
                        Icons.check_rounded,
                        size: 16.r,
                        color: colorScheme.onPrimary,
                      )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: dotColor.withValues(alpha: isDone ? 1 : 0.3),
                  ),
                ),
            ],
          ),
          SizedBox(width: AppConstants.paddingMD.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: AppConstants.paddingLG.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppConstants.paddingMD.w),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? colorScheme.primaryContainer.withValues(alpha: 0.35)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
                  border: isCurrent
                      ? Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.w,
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12.sp,
                        height: 1.5,
                      ),
                    ),
                    if (actionLabel != null) ...[
                      SizedBox(height: AppConstants.paddingMD.h),
                      CustomButton(
                        label: actionLabel!,
                        onPressed: isCurrent ? onAction : null,
                        isLoading: isLoading,
                        height: 44.h,
                        backgroundColor: isCurrent ? null : colorScheme.outline,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
