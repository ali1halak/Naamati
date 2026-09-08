import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/location/open_in_maps_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/available_request.dart';

/// One card on the charity's "الطلبات المتاحة" marketplace screen.
class AvailableRequestCard extends StatelessWidget {
  final AvailableRequest request;
  final VoidCallback onAccept;
  final bool isAccepting;

  const AvailableRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    this.isAccepting = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Thumbnail(request: request),
          Padding(
            padding: EdgeInsets.all(AppConstants.paddingMD.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title ?? 'طلب تبرع',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  (request.description != null &&
                          request.description!.trim().isNotEmpty)
                      ? request.description!
                      : (request.quantityDesc ?? ''),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 10.h),
                if (request.expiryDate != null)
                  _MetaRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'صلاحية',
                    value: request.expiryDate!,
                  ),
                if (request.pickupDeadline != null)
                  _MetaRow(
                    icon: Icons.schedule_rounded,
                    label: 'التسليم قبل',
                    value: request.pickupDeadline!,
                  ),
                if (request.locationZone != null &&
                    request.locationZone!.trim().isNotEmpty)
                  _MetaRow(
                    icon: Icons.location_on_outlined,
                    label: 'الموقع',
                    value: request.locationZone!,
                  ),
                if (request.latitude != null && request.longitude != null) ...[
                  SizedBox(height: 4.h),
                  OpenInMapsButton(
                    latitude: request.latitude,
                    longitude: request.longitude,
                  ),
                ],
                SizedBox(height: AppConstants.paddingSM.h),
                CustomButton(
                  label: 'قبول الطلب',
                  onPressed: onAccept,
                  isLoading: isAccepting,
                  height: 44.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final AvailableRequest request;

  const _Thumbnail({required this.request});

  IconData get _fallbackIcon {
    switch (request.categoryIcon) {
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
      default:
        return Icons.lunch_dining_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = request.imageUrl;

    return Stack(
      children: [
        SizedBox(
          height: 120.h,
          width: double.infinity,
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, _) => Container(
                    color: colorScheme.primaryContainer,
                    child: Icon(
                      _fallbackIcon,
                      size: 40.r,
                      color: colorScheme.primary,
                    ),
                  ),
                )
              : Container(
                  color: colorScheme.primaryContainer,
                  child: Icon(
                    _fallbackIcon,
                    size: 40.r,
                    color: colorScheme.primary,
                  ),
                ),
        ),
        Positioned(
          bottom: 8.h,
          right: 8.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: request.needsCooking
                  ? AppColors.warningContainer
                  : colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(
                AppConstants.radiusCircular.r,
              ),
            ),
            child: Text(
              request.foodStateLabelAr,
              style: TextStyle(
                color: request.needsCooking
                    ? AppColors.secondaryDark
                    : colorScheme.onPrimaryContainer,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 14.r, color: colorScheme.onSurfaceVariant),
          SizedBox(width: 6.w),
          Text(
            '$label: ',
            style: AppTextStyles.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11.sp,
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
