import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../donation/presentation/bloc/my_donations_cubit.dart';
import '../../../donation/presentation/bloc/my_donations_state.dart';
import '../../../donation/presentation/widgets/donation_card.dart';
import '../widgets/home_bottom_nav.dart';
import '../widgets/new_donation_card.dart';

/// Donor home screen — RTL layout matching the Figma design.
///
/// **حصرية للمتبرع (DONOR)** — لا تُعرض للجمعية.
/// تُعرض بعد تسجيل دخول المتبرع مباشرة (`accountType == 'donor'`).
///
/// Structure:
/// - White [AppBar] with hamburger, centered "نعمتي" title, avatar action.
/// - Light-beige body with a faint heart watermark and a centered dark-green
///   "طلب تبرع جديد" card.
/// - Tab 1 ("تبرعاتي"): the donor's real donations list, pulled from the API.
/// - Custom bottom navigation pill with "الرئيسية" / "تبرعاتي".
class DonorHomePage extends StatelessWidget {
  const DonorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Created above the whole subtree so nav callbacks and tabs can read it.
    return BlocProvider(
      create: (_) => sl<MyDonationsCubit>(),
      child: const _DonorHomeBody(),
    );
  }
}

/// Alias kept for backward compatibility — use [DonorHomePage].
typedef HomePage = DonorHomePage;

class _DonorHomeBody extends StatefulWidget {
  const _DonorHomeBody();

  @override
  State<_DonorHomeBody> createState() => _DonorHomeBodyState();
}

class _DonorHomeBodyState extends State<_DonorHomeBody> {
  int _selectedIndex = 0;

  void _onTapNav(int index) {
    setState(() => _selectedIndex = index);
    // Re-fetch on every visit so statuses stay fresh after tracking changes.
    if (index == 1) {
      context.read<MyDonationsCubit>().loadDonations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.brandBeige,
        appBar: _HomeAppBar(colorScheme: colorScheme),
        body: Stack(
          children: [
            const _HeartBackground(),
            if (_selectedIndex == 0) const _HomeContent() else const _MyDonationsTab(),
          ],
        ),
        bottomNavigationBar: HomeBottomNav(selectedIndex: _selectedIndex, onTap: _onTapNav),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ColorScheme colorScheme;

  const _HomeAppBar({required this.colorScheme});

  @override
  Size get preferredSize => Size.fromHeight(AppConstants.appBarHeight.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, size: 24.r, color: AppColors.textPrimaryLight),
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('القائمة قريباً')));
        },
      ),
      centerTitle: true,
      title: Text(
        'نعمتي',
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.brandGreen,
          fontWeight: FontWeight.w800,
          fontSize: 20.sp,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(left: 12.w, right: 4.w),
          child: GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primaryContainer,
              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=32'),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(height: 1.h, color: AppColors.divider.withValues(alpha: 0.6)),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMD.w,
                vertical: AppConstants.paddingLG.h,
              ),
              child: Center(
                child: NewDonationCard(
                  onTap: () => context.push(RouteNames.createDonation),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// "تبرعاتي" tab — the donor's donation history pulled from the API.
class _MyDonationsTab extends StatelessWidget {
  const _MyDonationsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyDonationsCubit, MyDonationsState>(
      builder: (context, state) {
        if (state.isLoading && state.donations.isEmpty) {
          return const Center(child: LoadingIndicator.fullScreen());
        }
        if (state.isFailure && state.donations.isEmpty) {
          return AppErrorWidget(
            message: state.errorMessage ?? 'تعذر تحميل التبرعات',
            retryLabel: 'إعادة المحاولة',
            onRetry: () => context.read<MyDonationsCubit>().loadDonations(),
          );
        }
        if (state.donations.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.volunteer_activism_rounded,
            title: 'لا توجد تبرعات بعد',
            subtitle: 'ابدأ أول تبرع لك من زر "طلب تبرع جديد" في الصفحة الرئيسية',
          );
        }

        return RefreshIndicator(
          color: AppColors.brandGreen,
          onRefresh: () => context.read<MyDonationsCubit>().loadDonations(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMD.w,
              vertical: AppConstants.paddingLG.h,
            ),
            itemCount: state.donations.length,
            separatorBuilder: (_, _) => SizedBox(height: AppConstants.paddingSM.h),
            itemBuilder: (context, index) {
              final donation = state.donations[index];
              return DonationCard(
                donation: donation,
                onTap: () => context.push(RouteNames.donationDetailsPath(donation.id)),
              );
            },
          ),
        );
      },
    );
  }
}

class _HeartBackground extends StatelessWidget {
  const _HeartBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.center,
          child: Opacity(
            opacity: 0.07,
            child: Icon(Icons.favorite_rounded, size: 420.r, color: AppColors.brandGreen),
          ),
        ),
      ),
    );
  }
}
