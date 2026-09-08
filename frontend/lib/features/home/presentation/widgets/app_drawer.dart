import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../profile/presentation/widgets/profile_avatar.dart';

/// Shared navigation drawer for both the donor and charity home screens.
///
/// [user] is passed in rather than fetched here — the home page already
/// loads it for its own app bar avatar and refreshes it whenever the user
/// returns from the profile screen, so the drawer's header always shows the
/// same (fresh) name/photo instead of a stale copy fetched once on open.
class AppDrawer extends StatelessWidget {
  /// Where "الرئيسية" navigates — differs between the donor and charity home.
  final String homeRoute;

  final User? user;

  const AppDrawer({super.key, required this.homeRoute, this.user});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
          ),
          title: Text('تسجيل الخروج', style: AppTextStyles.titleMedium),
          content: Text(
            'هل تريد تسجيل الخروج من حسابك؟',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('تراجع'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop(); // close the drawer first
      await sl<LogoutUseCase>()(const NoParams());
      if (context.mounted) context.go(RouteNames.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        backgroundColor: colorScheme.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DrawerHeader(user: user),
              SizedBox(height: AppConstants.paddingSM.h),
              _DrawerItem(
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(homeRoute);
                },
              ),
              _DrawerItem(
                icon: Icons.person_outline_rounded,
                label: 'الملف الشخصي',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(RouteNames.profile);
                },
              ),
              _DrawerItem(
                icon: Icons.settings_outlined,
                label: 'الإعدادات',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(RouteNames.settings);
                },
              ),
              _DrawerItem(
                icon: Icons.notifications_none_rounded,
                label: 'الإشعارات',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(RouteNames.notifications);
                },
              ),
              const Spacer(),
              Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 0.25),
              ),
              _DrawerItem(
                icon: Icons.logout_rounded,
                label: 'تسجيل الخروج',
                isDestructive: true,
                onTap: () => _confirmLogout(context),
              ),
              SizedBox(height: AppConstants.paddingSM.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final User? user;

  const _DrawerHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = user?.name ?? 'نِعْمَتِي';
    final roleLabel = user?.accountType == 'charity' ? 'جمعية خيرية' : 'متبرع';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingLG.w,
        AppConstants.paddingXL.h,
        AppConstants.paddingLG.w,
        AppConstants.paddingLG.h,
      ),
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileAvatar(imageUrl: user?.photoUrl, name: name, radius: 30),
          SizedBox(height: AppConstants.paddingMD.h),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.titleMedium.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            user?.email ?? roleLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? colorScheme.error : colorScheme.primary,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
      onTap: onTap,
    );
  }
}
