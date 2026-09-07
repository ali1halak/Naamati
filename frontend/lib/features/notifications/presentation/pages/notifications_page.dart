import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../domain/entities/app_notification.dart';
import '../bloc/notifications_cubit.dart';
import '../bloc/notifications_state.dart';
import '../widgets/notification_tile.dart';

/// Shared notifications feed for both roles (`GET /notifications` is scoped
/// server-side to whichever account's token is used) — reachable from the
/// drawer or the bell icon on either home screen.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>()..load(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final ScrollController _scrollController = ScrollController();

  /// Which tracking screen a tap navigates to — resolved once via the
  /// existing [GetCurrentUserUseCase] (no dedicated endpoint needed for
  /// this alone), since a donor's and a charity's own feeds never mix.
  bool _isCharity = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadRole();
  }

  Future<void> _loadRole() async {
    final result = await sl<GetCurrentUserUseCase>()(const NoParams());
    if (!mounted) return;
    result.fold(
      (_) {},
      (user) => setState(() => _isCharity = user.accountType == 'charity'),
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 400) {
      context.read<NotificationsCubit>().loadMore();
    }
  }

  void _onTapNotification(AppNotification notification) {
    context.read<NotificationsCubit>().markRead(notification.id);

    // Not yet accepted by this charity — send it to the board to review and
    // accept, not straight to a tracking screen it doesn't own yet.
    if (notification.kind == NotificationKind.newRequestAvailable) {
      context.push(RouteNames.charityHome);
      return;
    }

    final donationId = notification.donationRequestId;
    if (donationId == null) return;

    context.push(
      _isCharity
          ? RouteNames.charityOrderTrackingPath(donationId)
          : RouteNames.donationDetailsPath(donationId),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'الإشعارات',
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: LoadingIndicator.fullScreen());
            }
            if (state.isFailure) {
              return AppErrorWidget(
                message: state.errorMessage ?? 'تعذر تحميل الإشعارات',
                retryLabel: 'إعادة المحاولة',
                onRetry: () => context.read<NotificationsCubit>().load(),
              );
            }
            if (state.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.notifications_none_rounded,
                title: 'لا توجد إشعارات بعد',
                subtitle: 'ستظهر هنا آخر التحديثات على طلباتك.',
              );
            }

            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () => context.read<NotificationsCubit>().load(),
              child: ListView.separated(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: AppConstants.paddingSM.h,
                ),
                itemCount:
                    state.notifications.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: colorScheme.outline.withValues(alpha: 0.15),
                ),
                itemBuilder: (context, index) {
                  if (index >= state.notifications.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppConstants.paddingMD.h,
                      ),
                      child: const Center(child: LoadingIndicator.inline()),
                    );
                  }
                  final notification = state.notifications[index];
                  return NotificationTile(
                    notification: notification,
                    onTap: () => _onTapNotification(notification),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
