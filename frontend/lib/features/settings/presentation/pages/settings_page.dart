import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../profile/presentation/bloc/profile_cubit.dart';
import '../../../profile/presentation/widgets/profile_menu_tile.dart';
import '../../../profile/presentation/widgets/section_header.dart';
import '../widgets/change_password_sheet.dart';

/// "الإعدادات" — account management + app preferences, shared by both roles.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  late final SharedPreferences _prefs;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _prefs = sl<SharedPreferences>();
    _notificationsEnabled =
        _prefs.getBool(StorageKeys.notificationsEnabled) ?? true;
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await _prefs.setBool(StorageKeys.notificationsEnabled, value);
  }

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
      await sl<LogoutUseCase>()(const NoParams());
      if (context.mounted) context.go(RouteNames.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeCubit = context.watch<ThemeCubit>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            'الإعدادات',
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
        ),
        body: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.all(AppConstants.paddingMD.w),
          children: [
            const SectionHeader('الحساب'),
            ProfileMenuCard(
              tiles: [
                ProfileMenuTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'تغيير كلمة المرور',
                  onTap: () => ChangePasswordSheet.show(
                    context,
                    context.read<ProfileCubit>(),
                  ),
                ),
              ],
            ),
            const SectionHeader('التفضيلات'),
            ProfileMenuCard(
              tiles: [
                ProfileMenuTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'الوضع الداكن',
                  subtitle: themeCubit.state == ThemeMode.system
                      ? 'يتبع إعدادات الجهاز'
                      : null,
                  trailing: Switch(
                    value: themeCubit.isDark,
                    activeThumbColor: colorScheme.primary,
                    onChanged: themeCubit.toggleDark,
                  ),
                ),
                ProfileMenuTile(
                  icon: Icons.notifications_outlined,
                  title: 'الإشعارات',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    activeThumbColor: colorScheme.primary,
                    onChanged: _toggleNotifications,
                  ),
                ),
              ],
            ),
            const SectionHeader('حول التطبيق'),
            ProfileMenuCard(
              tiles: [
                ProfileMenuTile(
                  icon: Icons.info_outline_rounded,
                  title: 'إصدار التطبيق',
                  subtitle: AppConstants.appVersion,
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingMD.h),
            ProfileMenuCard(
              tiles: [
                ProfileMenuTile(
                  icon: Icons.logout_rounded,
                  title: 'تسجيل الخروج',
                  isDestructive: true,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingLG.h),
          ],
        ),
      ),
    );
  }
}
