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
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../home/presentation/widgets/app_drawer.dart';
import '../../../notifications/presentation/widgets/notification_bell_icon.dart';
import '../../../profile/presentation/widgets/profile_avatar.dart';
import '../../domain/entities/available_request.dart';
import '../../domain/entities/violation.dart';
import '../bloc/available_requests_cubit.dart';
import '../bloc/available_requests_state.dart';
import '../bloc/my_orders_cubit.dart';
import '../bloc/my_orders_state.dart';
import '../bloc/violations_cubit.dart';
import '../bloc/violations_state.dart';
import '../widgets/accept_request_sheet.dart';
import '../widgets/available_request_card.dart';
import '../widgets/charity_bottom_nav.dart';
import '../widgets/my_order_card.dart';
import '../widgets/violation_card.dart';

/// Charity home screen — RTL layout.
///
/// **حصرية للجمعية (CHARITY)** — تُعرض بعد تسجيل دخول جمعية مفعّلة.
/// ثلاث تبويبات، كلها مرتبطة بالباك اند بالكامل: "الطلبات المتاحة" (تصفح،
/// قبول)، "الطلبات السابقة" (سجل الطلبات المأخوذة)، "المخالفات" (سجل
/// الالتزام للقراءة فقط).
class CharityHomePage extends StatelessWidget {
  const CharityHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AvailableRequestsCubit>()..loadRequests(),
        ),
        BlocProvider(create: (_) => sl<MyOrdersCubit>()),
        BlocProvider(create: (_) => sl<ViolationsCubit>()),
      ],
      child: const _CharityHomeBody(),
    );
  }
}

class _CharityHomeBody extends StatefulWidget {
  const _CharityHomeBody();

  @override
  State<_CharityHomeBody> createState() => _CharityHomeBodyState();
}

class _CharityHomeBodyState extends State<_CharityHomeBody> {
  int _selectedIndex = 0;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final result = await sl<GetCurrentUserUseCase>()(const NoParams());
    if (!mounted) return;
    result.fold((_) {}, (user) => setState(() => _user = user));
  }

  void _onTapNav(int index) {
    setState(() => _selectedIndex = index);
    // Re-fetch on every visit so statuses stay fresh after tracking changes
    // (same convention as the donor home's tab switch).
    if (index == 1) {
      context.read<MyOrdersCubit>().loadOrders();
    } else if (index == 2) {
      context.read<ViolationsCubit>().loadViolations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _CharityHomeAppBar(
          colorScheme: Theme.of(context).colorScheme,
          user: _user,
          onProfileReturn: _loadUser,
        ),
        drawer: AppDrawer(homeRoute: RouteNames.charityHome, user: _user),
        body: switch (_selectedIndex) {
          0 => const _AvailableRequestsTab(),
          1 => const _MyOrdersTab(),
          _ => const _ViolationsTab(),
        },
        bottomNavigationBar: CharityBottomNav(
          selectedIndex: _selectedIndex,
          onTap: _onTapNav,
        ),
      ),
    );
  }
}

class _CharityHomeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final ColorScheme colorScheme;
  final User? user;
  final VoidCallback? onProfileReturn;

  const _CharityHomeAppBar({
    required this.colorScheme,
    this.user,
    this.onProfileReturn,
  });

  @override
  Size get preferredSize => Size.fromHeight(AppConstants.appBarHeight.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
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
      title: Text(
        'نعمتي',
        style: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
          fontSize: 20.sp,
        ),
      ),
      actions: [
        const NotificationBellIcon(),
        Padding(
          padding: EdgeInsets.only(left: 12.w, right: 4.w),
          child: GestureDetector(
            onTap: () async {
              await context.push(RouteNames.profile);
              onProfileReturn?.call();
            },
            child: ProfileAvatar(
              imageUrl: user?.photoUrl,
              name: user?.name ?? '',
              radius: 16,
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

/// "الطلبات المتاحة" tab — open requests fetched from
/// `GET /charity/requests/available`.
class _AvailableRequestsTab extends StatefulWidget {
  const _AvailableRequestsTab();

  @override
  State<_AvailableRequestsTab> createState() => _AvailableRequestsTabState();
}

class _AvailableRequestsTabState extends State<_AvailableRequestsTab> {
  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    _listController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_listController.hasClients) return;
    if (_listController.position.extentAfter < 400) {
      context.read<AvailableRequestsCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _accept(AvailableRequest request) async {
    final cubit = context.read<AvailableRequestsCubit>();
    final etaMinutes = await AcceptRequestSheet.show(
      context,
      latitude: request.latitude,
      longitude: request.longitude,
    );
    if (etaMinutes == null || !mounted) return;

    final accepted = await cubit.acceptRequest(
      request.id,
      etaMinutes: etaMinutes,
    );
    if (!mounted) return;

    if (accepted != null) {
      context.push(RouteNames.charityOrderTrackingPath(accepted.id));
    } else {
      final message = cubit.state.acceptErrorMessage ?? 'تعذر قبول الطلب';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvailableRequestsCubit, AvailableRequestsState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.paddingMD.w,
                AppConstants.paddingLG.h,
                AppConstants.paddingMD.w,
                AppConstants.paddingSM.h,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'الطلبات المتاحة',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22.sp,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AvailableRequestsState state) {
    final cubit = context.read<AvailableRequestsCubit>();

    if (state.isLoading && state.requests.isEmpty) {
      return const Center(child: LoadingIndicator.fullScreen());
    }
    if (state.isFailure && state.requests.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage ?? 'تعذر تحميل الطلبات المتاحة',
        retryLabel: 'إعادة المحاولة',
        onRetry: () => cubit.loadRequests(),
      );
    }
    if (state.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.inbox_rounded,
        title: 'لا توجد طلبات متاحة حالياً',
        subtitle: 'سيظهر هنا كل طلب تبرع جديد بانتظار قبول جمعية.',
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => cubit.loadRequests(),
      child: ListView.separated(
        controller: _listController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppConstants.paddingMD.w,
          0,
          AppConstants.paddingMD.w,
          AppConstants.paddingLG.h,
        ),
        itemCount: state.requests.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, _) => SizedBox(height: 14.h),
        itemBuilder: (context, index) {
          if (index == state.requests.length) {
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
          final request = state.requests[index];
          return AvailableRequestCard(
            request: request,
            onAccept: () => _accept(request),
            isAccepting: state.acceptingId == request.id,
          );
        },
      ),
    );
  }
}

/// "الطلبات السابقة" tab — this charity's own work queue and history,
/// fetched from `GET /charity/requests`.
class _MyOrdersTab extends StatefulWidget {
  const _MyOrdersTab();

  @override
  State<_MyOrdersTab> createState() => _MyOrdersTabState();
}

class _MyOrdersTabState extends State<_MyOrdersTab> {
  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    _listController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_listController.hasClients) return;
    if (_listController.position.extentAfter < 400) {
      context.read<MyOrdersCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyOrdersCubit, MyOrdersState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.paddingMD.w,
                AppConstants.paddingLG.h,
                AppConstants.paddingMD.w,
                AppConstants.paddingSM.h,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'الطلبات السابقة',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22.sp,
                  ),
                ),
              ),
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MyOrdersState state) {
    final cubit = context.read<MyOrdersCubit>();

    if (state.isLoading && state.orders.isEmpty) {
      return const Center(child: LoadingIndicator.fullScreen());
    }
    if (state.isFailure && state.orders.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage ?? 'تعذر تحميل الطلبات',
        retryLabel: 'إعادة المحاولة',
        onRetry: () => cubit.loadOrders(),
      );
    }
    if (state.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history_rounded,
        title: 'لا توجد طلبات سابقة',
        subtitle: 'سيظهر هنا كل طلب أخذته من قبل.',
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => cubit.loadOrders(),
      child: ListView.separated(
        controller: _listController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppConstants.paddingMD.w,
          0,
          AppConstants.paddingMD.w,
          AppConstants.paddingLG.h,
        ),
        itemCount: state.orders.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, _) => SizedBox(height: 14.h),
        itemBuilder: (context, index) {
          if (index == state.orders.length) {
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
          final order = state.orders[index];
          return MyOrderCard(
            order: order,
            // Still actionable (accepted/picked_up) → the tracking screen,
            // where confirming pickup/distribution actually happens. Only a
            // terminal order (completed/expired/cancelled/no_show) goes to
            // the read-only audit — otherwise a charity mid-handover would
            // land on a dead end with no way to continue.
            onTap: () => context.push(
              order.status.isActive
                  ? RouteNames.charityOrderTrackingPath(order.id)
                  : RouteNames.charityOrderDetailsPath(order.id),
            ),
          );
        },
      ),
    );
  }
}

/// "المخالفات" tab — this charity's own compliance record, read-only,
/// fetched from `GET /charity/violations`.
class _ViolationsTab extends StatefulWidget {
  const _ViolationsTab();

  @override
  State<_ViolationsTab> createState() => _ViolationsTabState();
}

class _ViolationsTabState extends State<_ViolationsTab> {
  final ScrollController _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    _listController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_listController.hasClients) return;
    if (_listController.position.extentAfter < 400) {
      context.read<ViolationsCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViolationsCubit, ViolationsState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.paddingMD.w,
                AppConstants.paddingLG.h,
                AppConstants.paddingMD.w,
                AppConstants.paddingSM.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سجل المخالفات',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'مراجعة المخالفات المسجلة لضمان جودة الخدمة والالتزام بالمعايير.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13.sp,
                    ),
                  ),
                  if (state.compliance != null) ...[
                    SizedBox(height: 10.h),
                    _ComplianceBanner(compliance: state.compliance!),
                  ],
                ],
              ),
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ViolationsState state) {
    final cubit = context.read<ViolationsCubit>();

    if (state.isLoading && state.violations.isEmpty) {
      return const Center(child: LoadingIndicator.fullScreen());
    }
    if (state.isFailure && state.violations.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage ?? 'تعذر تحميل سجل المخالفات',
        retryLabel: 'إعادة المحاولة',
        onRetry: () => cubit.loadViolations(),
      );
    }
    if (state.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.verified_outlined,
        title: 'لا توجد مخالفات',
        subtitle: 'سجلك نظيف — استمروا على هذا الالتزام.',
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () => cubit.loadViolations(),
      child: ListView.separated(
        controller: _listController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppConstants.paddingMD.w,
          0,
          AppConstants.paddingMD.w,
          AppConstants.paddingLG.h,
        ),
        itemCount: state.violations.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, _) => SizedBox(height: 14.h),
        itemBuilder: (context, index) {
          if (index == state.violations.length) {
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
          return ViolationCard(violation: state.violations[index]);
        },
      ),
    );
  }
}

class _ComplianceBanner extends StatelessWidget {
  final ComplianceInfo compliance;

  const _ComplianceBanner({required this.compliance});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ratio = compliance.suspensionThreshold > 0
        ? (compliance.totalWeight / compliance.suspensionThreshold).clamp(
            0.0,
            1.0,
          )
        : 0.0;
    final isCloseToSuspension = ratio >= 0.7;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMD.w,
        vertical: AppConstants.paddingSM.h,
      ),
      decoration: BoxDecoration(
        color: isCloseToSuspension
            ? AppColors.errorContainer
            : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
      ),
      child: Row(
        children: [
          Icon(
            isCloseToSuspension
                ? Icons.warning_amber_rounded
                : Icons.shield_outlined,
            size: 18.r,
            color: isCloseToSuspension ? AppColors.error : colorScheme.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'وزن المخالفات: ${compliance.totalWeight} من ${compliance.suspensionThreshold} — تجاوزه يوقف الحساب تلقائياً.',
              style: AppTextStyles.labelSmall.copyWith(
                color: isCloseToSuspension
                    ? AppColors.error
                    : colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
