import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
/// - Custom bottom navigation pill with "الرئيسية" / "تبرعاتي".
class DonorHomePage extends StatefulWidget {
  const DonorHomePage({super.key});

  @override
  State<DonorHomePage> createState() => _DonorHomePageState();
}

/// Alias kept for backward compatibility — use [DonorHomePage].
typedef HomePage = DonorHomePage;

class _DonorHomePageState extends State<DonorHomePage> {
  int _selectedIndex = 0;

  void _onTapNav(int index) {
    setState(() => _selectedIndex = index);
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
            if (_selectedIndex == 0) const _HomeContent() else const _MyDonationsPlaceholder(),
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
                  onTap: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('إنشاء طلب تبرع جديد')));
                  },
                ),
              ),
            ),
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
        child: Center(
          child: Opacity(
            opacity: 0.07,
            child: Icon(Icons.favorite_rounded, size: 420.r, color: AppColors.brandGreen),
          ),
        ),
      ),
    );
  }
}

class _MyDonationsPlaceholder extends StatelessWidget {
  const _MyDonationsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingXL.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
              child: Icon(
                Icons.volunteer_activism_rounded,
                size: 36.r,
                color: AppColors.brandGreen,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'تبرعاتي',
              style: textTheme.titleLarge?.copyWith(color: AppColors.brandGreen, fontSize: 20.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'لا توجد تبرعات بعد',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
