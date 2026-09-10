import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Custom bottom navigation pill with three items, matching [HomeBottomNav]'s
/// look for the charity side.
class CharityBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  /// Total open requests this charity could take right now.
  final int availableCount;

  /// Total violations on file — shown as a warning badge, not a "new" count.
  final int violationsCount;

  const CharityBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.availableCount = 0,
    this.violationsCount = 0,
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
                  badgeCount: availableCount,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.history_rounded,
                  label: 'الطلبات السابقة',
                  selected: selectedIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.report_gmailerrorred_rounded,
                  label: 'المخالفات',
                  selected: selectedIndex == 2,
                  badgeCount: violationsCount,
                  isWarningBadge: true,
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
  final int badgeCount;

  /// Red (compliance warning) instead of the default primary-colored count.
  final bool isWarningBadge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
    this.isWarningBadge = false,
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 5.h,
                  ),
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
                if (badgeCount > 0)
                  Positioned(
                    right: 4.w,
                    top: -2.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.r),
                      constraints: BoxConstraints(
                        minWidth: 16.r,
                        minHeight: 16.r,
                      ),
                      decoration: BoxDecoration(
                        color: isWarningBadge
                            ? colorScheme.error
                            : colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 1.5.w,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isWarningBadge
                                ? colorScheme.onError
                                : colorScheme.onPrimary,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
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
