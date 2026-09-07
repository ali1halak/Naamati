import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../domain/entities/my_profile.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_menu_tile.dart';

/// "الملف الشخصي" — the signed-in donor/charity's own profile, shared by
/// both roles (backend resolves which one from the auth token).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

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
            'الملف الشخصي',
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
              context.read<ProfileCubit>().consumeSuccessMessage();
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.profile == null) {
              return const Center(child: LoadingIndicator.fullScreen());
            }
            if (state.isFailure && state.profile == null) {
              return AppErrorWidget(
                message: state.errorMessage ?? 'تعذر تحميل الملف الشخصي',
                retryLabel: 'إعادة المحاولة',
                onRetry: () => context.read<ProfileCubit>().load(),
              );
            }
            final profile = state.profile;
            if (profile == null) return const SizedBox.shrink();

            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () => context.read<ProfileCubit>().load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.all(AppConstants.paddingMD.w),
                children: [
                  _ProfileHeaderCard(profile: profile),
                  SizedBox(height: AppConstants.paddingLG.h),
                  ProfileMenuCard(
                    tiles: [
                      ProfileMenuTile(
                        icon: Icons.edit_rounded,
                        title: 'تعديل الملف الشخصي',
                        onTap: () async {
                          final cubit = context.read<ProfileCubit>();
                          await context.push(
                            RouteNames.editProfile,
                            extra: profile,
                          );
                          cubit.load();
                        },
                      ),
                      ProfileMenuTile(
                        icon: Icons.settings_rounded,
                        title: 'الإعدادات',
                        onTap: () => context.push(RouteNames.settings),
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
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final MyProfile profile;

  const _ProfileHeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final charity = profile.charity;
    final donor = profile.donor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.paddingLG.w),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileAvatar(
            imageUrl: profile.avatarUrl,
            name: profile.name,
            radius: 40,
          ),
          SizedBox(height: AppConstants.paddingMD.h),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            profile.email,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          if (charity != null) ...[
            SizedBox(height: AppConstants.paddingSM.h),
            _StatusPill(label: charity.statusLabel, isActive: charity.isActive),
          ],
          SizedBox(height: AppConstants.paddingLG.h),
          Row(
            children: charity != null
                ? [
                    _StatItem(
                      icon: Icons.star_rounded,
                      value: charity.ratingAvg != null
                          ? charity.ratingAvg!.toStringAsFixed(1)
                          : '—',
                      label: '${charity.ratingsCount} تقييم',
                    ),
                    _StatItem(
                      icon: Icons.volunteer_activism_rounded,
                      value: '${charity.completedDonationsCount}',
                      label: 'تبرع مكتمل',
                    ),
                  ]
                : [
                    _StatItem(
                      icon: Icons.volunteer_activism_rounded,
                      value: '${donor?.completedDonationsCount ?? 0}',
                      label: 'تبرع مكتمل',
                    ),
                    _StatItem(
                      icon: Icons.event_available_rounded,
                      value: donor?.memberSince ?? '—',
                      label: 'عضو منذ',
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final bool isActive;

  const _StatusPill({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isActive ? AppColors.successLight : AppColors.warningLight;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusCircular.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20.r, color: onPrimary.withValues(alpha: 0.9)),
          SizedBox(height: 6.h),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: onPrimary.withValues(alpha: 0.75),
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}
