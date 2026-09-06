import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/donation_request.dart';

/// Surface-colored rounded card listing the donation's key details — reused
/// on the pending screen, the accepted/details screen and terminal states.
class DonationSummaryCard extends StatelessWidget {
  final DonationRequest donation;

  const DonationSummaryCard({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMD.w,
        vertical: AppConstants.paddingMD.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
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
            value: int.tryParse(donation.quantityDesc) != null
                ? '${donation.quantityDesc} شخص'
                : donation.quantityDesc,
          ),
          _SummaryRow(
            icon: donation.needsCooking
                ? Icons.soup_kitchen_rounded
                : Icons.restaurant_rounded,
            label: 'حالة الطعام',
            value: donation.foodStateLabelAr,
          ),
          _SummaryRow(
            icon: Icons.schedule_rounded,
            label: 'آخر وقت للاستلام',
            value: DateFormatter.formatDateTime(donation.pickupUntil),
            highlight: true,
          ),
          if (donation.description != null &&
              donation.description!.trim().isNotEmpty)
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
          if (donation.pickupNotes != null &&
              donation.pickupNotes!.trim().isNotEmpty)
            _SummaryRow(
              icon: Icons.directions_rounded,
              label: 'ملاحظات الوصول',
              value: donation.pickupNotes!,
            ),
          _SummaryRow(
            icon: Icons.phone_outlined,
            label: 'رقم التواصل',
            value: donation.contactPhone,
          ),
          if (donation.images.isNotEmpty) ...[
            SizedBox(height: AppConstants.paddingSM.h),
            SizedBox(
              height: 96.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: donation.images.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
                  child: Image.network(
                    donation.images[index],
                    width: 96.r,
                    height: 96.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, _) => Container(
                      width: 96.r,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppConstants.paddingSM.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: highlight
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 17.r,
              color: highlight
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
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
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colorScheme.onSurface,
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
