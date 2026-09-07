import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../donation/domain/entities/donation_request.dart';
import '../../../donation/presentation/widgets/donation_status_style.dart';

/// One card on the charity's "الطلبات السابقة" (my orders/history) tab —
/// read-only, tapping opens the full order audit.
class MyOrderCard extends StatelessWidget {
  final DonationRequest order;
  final VoidCallback onTap;

  const MyOrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = kDonationStatusStyles[order.status]!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
        child: Ink(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.title ?? 'طلب تبرع',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '#${order.id.toString().padLeft(5, '0')}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: style.background,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMD.r,
                      ),
                    ),
                    child: Text(
                      order.statusLabel ?? order.status.labelAr,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: style.foreground,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                (order.description != null &&
                        order.description!.trim().isNotEmpty)
                    ? order.description!
                    : 'الكمية التقديرية: ${order.quantity} شخص',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13.r,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    order.createdAtLabel ??
                        DateFormatter.formatArabicDate(order.createdAt),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
