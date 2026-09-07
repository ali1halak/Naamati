import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/donation_request.dart';
import '../../domain/entities/donation_status.dart';
import 'donation_status_style.dart';

/// List item for one donation in "تبرعاتي السابقة" matching the Figma design.
///
/// When [onEdit]/[onCancel] are provided and the donation is still editable
/// (pending), a footer row with edit + cancel actions is rendered; cancel
/// alone survives for accepted requests.
class DonationCard extends StatelessWidget {
  final DonationRequest donation;
  final VoidCallback? onTap;

  /// Opens the tracking screen for this card; shown for active states.
  final VoidCallback? onTrack;

  /// Opens the edit form for this card; null hides the button.
  final VoidCallback? onEdit;

  /// Opens the cancel confirmation for this card; null hides the button.
  final VoidCallback? onCancel;

  /// Whether this card's cancel request is in flight (spinner state).
  final bool isCancelling;

  const DonationCard({
    super.key,
    required this.donation,
    this.onTap,
    this.onTrack,
    this.onEdit,
    this.onCancel,
    this.isCancelling = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusConfig = _getStatusConfig(
      donation.status,
      donation.statusLabel,
    );
    final showCancel = onCancel != null && donation.canCancel;
    // Editing is safe only before a charity claims the request.
    final showEdit = onEdit != null && donation.status == DonationStatus.pending;
    // Active requests have a live status worth following.
    final showTracking = onTrack != null && donation.status.isActive;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMD.w,
            vertical: 14.h,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.35),
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
              // ── Circular food icon container (photo when available) ───────
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: (donation.images.isNotEmpty)
                    ? Image.network(
                        donation.images.first,
                        width: 48.r,
                        height: 48.r,
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, _) => Icon(
                          _getCategoryIcon(
                            donation.categoryIconKey,
                            donation.title ?? donation.foodCategory?.nameAr,
                          ),
                          size: 24.r,
                          color: colorScheme.primary,
                        ),
                      )
                    : Icon(
                        _getCategoryIcon(
                          donation.categoryIconKey,
                          donation.title ?? donation.foodCategory?.nameAr,
                        ),
                        size: 24.r,
                        color: colorScheme.primary,
                      ),
              ),
              SizedBox(width: 12.w),

              // ── Middle details (Title, Description, Date) ─────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donation.title ??
                          donation.foodCategory?.nameAr ??
                          'طلب تبرع',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      (donation.description != null &&
                              donation.description!.trim().isNotEmpty)
                          ? donation.description!
                          : 'الكمية التقديرية: ${donation.quantity} شخص',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12.sp,
                        height: 1.3,
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
                        Flexible(
                          child: Text(
                            donation.createdAtLabel ??
                                DateFormatter.formatArabicDate(
                                  donation.createdAt,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Estimated people count (quantity is a number now).
                        ...[
                          SizedBox(width: 10.w),
                          Icon(
                            Icons.groups_rounded,
                            size: 13.r,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              '${donation.quantity} شخص',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // ── Status Badge pill (same palette the filter chips use) ────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: statusConfig.backgroundColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.r,
                      height: 6.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusConfig.textColor,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      statusConfig.label,
                      style: TextStyle(
                        color: statusConfig.textColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
              // ── Footer actions: tracking + edit (pending) + cancel ────────
              if (showTracking || showEdit || showCancel) ...[
                SizedBox(height: 10.h),
                Row(
                  children: [
                    if (showTracking) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onTrack,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.4),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusMD.r,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.route_rounded, size: 16),
                          label: Text(
                            'متابعة',
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (showEdit || showCancel) SizedBox(width: 8.w),
                    ],
                    if (showEdit) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(
                              color: colorScheme.primary.withValues(alpha: 0.4),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusMD.r,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: Text(
                            'تعديل',
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (showCancel) SizedBox(width: 8.w),
                    ],
                    if (showCancel)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isCancelling ? null : onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(
                              color: colorScheme.error.withValues(alpha: 0.4),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusMD.r,
                              ),
                            ),
                          ),
                          icon: isCancelling
                              ? SizedBox(
                                  width: 16.r,
                                  height: 16.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.error,
                                  ),
                                )
                              : const Icon(Icons.close_rounded, size: 16),
                          label: Text(
                            isCancelling ? 'جارٍ الإلغاء...' : 'إلغاء الطلب',
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? iconKey, String? categoryName) {
    if (iconKey != null) {
      switch (iconKey) {
        case 'cooked_ready':
          return Icons.restaurant_rounded;
        case 'canned_dry':
          return Icons.inventory_2_outlined;
        case 'bakery_sweets':
          return Icons.bakery_dining_rounded;
        case 'fruits_vegetables':
          return Icons.eco_rounded;
        case 'raw_meat':
          return Icons.set_meal_rounded;
        case 'raw_grains':
          return Icons.grass_rounded;
      }
    }

    final name = categoryName ?? '';
    if (name.contains('مخبوز') || name.contains('خبز')) {
      return Icons.bakery_dining_rounded;
    } else if (name.contains('تموين') || name.contains('جاف')) {
      return Icons.inventory_2_outlined;
    } else if (name.contains('خضار') ||
        name.contains('فواكه') ||
        name.contains('سلة')) {
      return Icons.eco_rounded;
    } else if (name.contains('عائلي') ||
        name.contains('فردي') ||
        name.contains('وجب')) {
      return Icons.restaurant_rounded;
    }

    return Icons.lunch_dining_rounded;
  }

  _StatusConfig _getStatusConfig(DonationStatus status, String? apiLabel) {
    final style = kDonationStatusStyles[status]!;
    return _StatusConfig(
      label: apiLabel ?? status.labelAr,
      backgroundColor: style.background,
      textColor: style.foreground,
    );
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}
