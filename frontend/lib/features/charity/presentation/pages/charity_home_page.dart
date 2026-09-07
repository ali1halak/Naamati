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
import '../bloc/available_requests_cubit.dart';
import '../bloc/available_requests_state.dart';
import '../widgets/accept_request_sheet.dart';
import '../widgets/available_request_card.dart';
import '../widgets/charity_bottom_nav.dart';

/// Charity home screen — RTL layout.
///
/// **حصرية للجمعية (CHARITY)** — تُعرض بعد تسجيل دخول جمعية مفعّلة.
/// تبويب "الطلبات المتاحة" مرتبط بالباك اند بالكامل (تصفح، قبول، متابعة).
/// تبويبا "الطلبات النشطة" و"المكتملات" قيد التطوير.
class CharityHomePage extends StatelessWidget {
  const CharityHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AvailableRequestsCubit>()..loadRequests(),
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _CharityHomeAppBar(colorScheme: Theme.of(context).colorScheme),
        body: switch (_selectedIndex) {
          0 => const _AvailableRequestsTab(),
          1 => const _ComingSoonTab(title: 'الطلبات النشطة'),
          _ => const _ComingSoonTab(title: 'المكتملات'),
        },
        bottomNavigationBar: CharityBottomNav(
          selectedIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}

class _CharityHomeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final ColorScheme colorScheme;

  const _CharityHomeAppBar({required this.colorScheme});

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
      title: Text(
        'نعمتي',
        style: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
          fontSize: 20.sp,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(left: 12.w, right: 4.w),
          child: GestureDetector(
            onTap: () => context.push(RouteNames.profile),
            child: CircleAvatar(
              radius: 16.r,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.home_work_rounded,
                size: 18.r,
                color: colorScheme.primary,
              ),
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

  Future<void> _accept(int id) async {
    final cubit = context.read<AvailableRequestsCubit>();
    final etaMinutes = await AcceptRequestSheet.show(context);
    if (etaMinutes == null || !mounted) return;

    final accepted = await cubit.acceptRequest(id, etaMinutes: etaMinutes);
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
            onAccept: () => _accept(request.id),
            isAccepting: state.acceptingId == request.id,
          );
        },
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  final String title;

  const _ComingSoonTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.hourglass_top_rounded,
      title: title,
      subtitle: 'هذا القسم قيد التطوير حالياً.',
    );
  }
}
