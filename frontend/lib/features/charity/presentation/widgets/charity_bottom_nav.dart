import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Custom bottom navigation pill with three items, matching [HomeBottomNav]'s
/// look for the charity side.
class CharityBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CharityBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 20.r,
            offset: Offset(0, -4.h),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
            width: 1.w,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMD.w,
            vertical: 8.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.storefront_rounded,
                  label: 'الطلبات المتاحة',
                  selected: selectedIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.local_shipping_rounded,
                  label: 'الطلبات النشطة',
                  selected: selectedIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.task_alt_rounded,
                  label: 'المكتملات',
                  selected: selectedIndex == 2,
                  onTap: () => onTap(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color textColor = selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusCircular.r,
                ),
              ),
              child: Icon(icon, size: 22.r, color: textColor),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                color: textColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
