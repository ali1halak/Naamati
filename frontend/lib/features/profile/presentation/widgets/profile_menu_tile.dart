import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One row inside a rounded card group on the Profile/Settings/Drawer
/// screens: a colored icon chip, a title (+ optional subtitle), and either a
/// trailing chevron (navigation) or a [trailing] widget (e.g. a [Switch]).
class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  /// Tints the icon chip and title red — used for destructive actions
  /// (e.g. logout).
  final bool isDestructive;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tint = isDestructive ? colorScheme.error : colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMD.w,
            vertical: 12.h,
          ),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 19.r, color: tint),
              ),
              SizedBox(width: AppConstants.paddingMD.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDestructive
                            ? colorScheme.error
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.chevron_left_rounded,
                  size: 22.r,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Groups [ProfileMenuTile]s in one rounded card with dividers between them —
/// the shared container both the Profile and Settings pages use.
class ProfileMenuCard extends StatelessWidget {
  final List<Widget> tiles;

  const ProfileMenuCard({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i != tiles.length - 1)
              Divider(
                height: 1,
                indent:
                    AppConstants.paddingMD.w + 38.r + AppConstants.paddingMD.w,
                color: colorScheme.outline.withValues(alpha: 0.25),
              ),
          ],
        ],
      ),
    );
  }
}
