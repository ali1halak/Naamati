import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../donation/presentation/bloc/my_donations_cubit.dart';
import '../../../donation/presentation/bloc/my_donations_state.dart';
import '../../../donation/presentation/widgets/donation_card.dart';
import '../../../donation/presentation/widgets/my_donations_filter_bar.dart';
import '../../../donation/domain/entities/donation_status.dart';
import '../../../donation/domain/entities/my_donations_filter.dart';
import '../widgets/app_drawer.dart';
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

  // The Scaffold carries the theme's beige/dark background itself; the heart
  // watermark is layered behind the tab content inside the body so it stays
  // dead-center regardless of which tab or state is showing.
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _HomeAppBar(colorScheme: Theme.of(context).colorScheme),
        drawer: const AppDrawer(homeRoute: RouteNames.home),
        body: Stack(
          children: [
            const _HeartBackground(),
            if (_selectedIndex == 0)
              const _HomeContent()
            else
              const _MyDonationsTab(),
          ],
        ),
        bottomNavigationBar: HomeBottomNav(
          selectedIndex: _selectedIndex,
          onTap: _onTapNav,
        ),
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
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu_rounded,
            size: 24.r,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      centerTitle: true,
      title: Text(
        'نعمتي',
        style: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
          fontSize: 20.sp,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded,
            size: 24.r,
            color: colorScheme.onSurface,
          ),
          onPressed: () => context.push(RouteNames.notifications),
        ),
        Padding(
          padding: EdgeInsets.only(left: 12.w, right: 4.w),
          child: GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 16.r,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?img=32',
              ),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(
          height: 1.h,
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
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

class _CancelDialog extends StatefulWidget {
  const _CancelDialog();

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
        ),
        title: Text('إلغاء الطلب', style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'هل أنت متأكد من إلغاء طلب التبرع؟',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppConstants.paddingMD.h),
            TextField(
              controller: _reasonController,
              maxLength: 255,
              decoration: const InputDecoration(hintText: 'السبب (اختياري)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_reasonController.text.trim()),
            child: Text(
              'نعم، إلغاء',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// "تبرعاتي" tab — the donor's donation history pulled from the API.
///
/// Fixed header (title + subtitle + search row + status chips) above a
/// scrolling list. The search field and the advanced-filters button (pinned
/// at the search row's end) filter server-side; the chips row filters by
/// status, and the sheet adds category / cooking state / date range.
class _MyDonationsTab extends StatefulWidget {
  const _MyDonationsTab();

  @override
  State<_MyDonationsTab> createState() => _MyDonationsTabState();
}

class _MyDonationsTabState extends State<_MyDonationsTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _listController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    // Restore the query if a filter was applied before the tab was rebuilt.
    _searchController.text =
        context.read<MyDonationsCubit>().state.filter.query ?? '';
    // Infinite scroll: fetch the next page as the list nears its end.
    _listController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_listController.hasClients) return;
    if (_listController.position.extentAfter < 400) {
      context.read<MyDonationsCubit>().loadMore();
    }
  }

  /// Donor's voluntary cancel: confirm (with optional reason), then cancel
  /// server-side and refresh the list.
  Future<void> _confirmCancel(int donationId) async {
    final cubit = context.read<MyDonationsCubit>();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _CancelDialog(),
    );

    if (result == null || !mounted) return;

    final reason = result.trim();
    final ok = await cubit.cancelDonation(
      donationId,
      reason: reason.isEmpty ? null : reason,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'تم إلغاء الطلب' : 'تعذر إلغاء الطلب')),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _listController.dispose();
    super.dispose();
  }

  /// Debounced server-side search — fires 350ms after the user stops typing.
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final current = context.read<MyDonationsCubit>().state.filter;
      final query = value.trim();
      context.read<MyDonationsCubit>().loadDonations(
        filter: MyDonationsFilter(
          query: query.isEmpty ? null : query,
          status: current.status,
          categoryId: current.categoryId,
          needsCooking: current.needsCooking,
          fromDate: current.fromDate,
          toDate: current.toDate,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<MyDonationsCubit, MyDonationsState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.paddingMD.w,
                AppConstants.paddingLG.h,
                AppConstants.paddingMD.w,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تبرعاتي السابقة',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 24.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'سجل عطائك ومساهماتك السابقة.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Search field with the advanced-filters button pinned at
                  // its end.
                  Row(
                    children: [
                      Expanded(
                        child: _DonationSearchField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      MyDonationsFilterButton(
                        filter: state.filter,
                        onFilterChanged: (filter) => context
                            .read<MyDonationsCubit>()
                            .loadDonations(filter: filter),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  MyDonationsStatusChips(
                    filter: state.filter,
                    onFilterChanged: (filter) => context
                        .read<MyDonationsCubit>()
                        .loadDonations(filter: filter),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MyDonationsState state) {
    final cubit = context.read<MyDonationsCubit>();
    final isFiltered = state.filter.hasActiveFilters;

    if (state.isLoading && state.donations.isEmpty) {
      return const Center(child: LoadingIndicator.fullScreen());
    }
    if (state.isFailure && state.donations.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage ?? 'تعذر تحميل التبرعات',
        retryLabel: 'إعادة المحاولة',
        onRetry: () => cubit.loadDonations(),
      );
    }
    if (state.isEmpty) {
      return isFiltered
          ? EmptyStateWidget(
              icon: Icons.filter_alt_off_rounded,
              title: 'لا توجد نتائج مطابقة',
              subtitle: 'جرّب توسيع الفلاتر أو مسحها لعرض كل التبرعات',
              action: TextButton(
                onPressed: () {
                  _searchController.clear();
                  cubit.loadDonations(filter: MyDonationsFilter.empty);
                },
                child: const Text('مسح الفلاتر'),
              ),
            )
          : const EmptyStateWidget(
              icon: Icons.volunteer_activism_rounded,
              title: 'لا توجد تبرعات بعد',
              subtitle:
                  'ابدأ أول تبرع لك من زر "طلب تبرع جديد" في الصفحة الرئيسية',
            );
    }

    return Stack(
      children: [
        RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () => cubit.loadDonations(),
          child: ListView.separated(
            controller: _listController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              AppConstants.paddingMD.w,
              12.h,
              AppConstants.paddingMD.w,
              AppConstants.paddingLG.h,
            ),
            // One extra footer slot while another page can still load.
            itemCount: state.donations.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              // Footer spinner for the in-flight next page.
              if (index == state.donations.length) {
                if (!state.isLoadingMore) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  child: Center(
                    child: SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                );
              }
              final donation = state.donations[index];
              return DonationCard(
                donation: donation,
                onTap: () =>
                    context.push(RouteNames.donationAuditPath(donation.id)),
                onTrack: donation.status.isActive
                    ? () => context.push(
                        RouteNames.donationDetailsPath(donation.id),
                      )
                    : null,
                onEdit: donation.status == DonationStatus.pending
                    ? () =>
                          context.push(RouteNames.donationEdit, extra: donation)
                    : null,
                onCancel: () => _confirmCancel(donation.id),
                isCancelling: state.cancellingId == donation.id,
              );
            },
          ),
        ),
        // Subtle progress bar while a filtered re-fetch updates the list.
        if (state.isRefining)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2.5,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Rounded search field for the "تبرعاتي" header.
class _DonationSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _DonationSearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20.r,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: Icon(
                Icons.close_rounded,
                size: 18.r,
                color: colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
        hintText: 'ابحث في تبرعاتك...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          fontSize: 13.sp,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _HeartBackground extends StatelessWidget {
  const _HeartBackground();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Container(
            width: 560.r,
            height: 560.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primary.withValues(alpha: 0.10),
                  primary.withValues(alpha: 0.05),
                  primary.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
            child: Opacity(
              opacity: 0.08,
              child: Icon(Icons.favorite_rounded, size: 320.r, color: primary),
            ),
          ),
        ),
      ),
    );
  }
}
