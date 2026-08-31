import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Custom bottom navigation pill with two items.
///
/// Selected item shows a pill background behind the icon ([AppColors.primaryContainer])
/// and green text — matching the screenshot.
class HomeBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20.r,
            offset: Offset(0, -4.h),
          ),
        ],
        border: Border(
          top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5), width: 1.w),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMD.w, vertical: 8.h),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_rounded,
                  label: 'الرئيسية',
                  selected: selectedIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.volunteer_activism_rounded,
                  label: 'تبرعاتي',
                  selected: selectedIndex == 1,
                  onTap: () => onTap(1),
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
    final Color textColor = selected ? AppColors.brandGreen : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.radiusCircular.r),
              ),
              child: Icon(icon, size: 22.r, color: textColor),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: textColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
