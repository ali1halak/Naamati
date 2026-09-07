import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../donation/domain/entities/donation_request.dart';
import '../../../donation/domain/entities/donation_status.dart';
import '../../../donation/presentation/widgets/donation_summary_card.dart';
import '../bloc/order_tracking_cubit.dart';
import '../bloc/order_tracking_state.dart';
import '../widgets/order_tracking_step.dart';

/// Charity's order-tracking screen ("متابعة الطلب") — the timeline of
/// قبول الطلب → تأكيد أخذ الطلب → تأكيد توزيع الطلب.
///
/// The status auto-refreshes every 15s while the order is active so the
/// donor's half of the two-sided handover confirmation reflects on screen
/// without a manual pull-to-refresh.
class OrderTrackingPage extends StatelessWidget {
  final int orderId;

  const OrderTrackingPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrderTrackingCubit>()
        ..load(orderId)
        ..startAutoRefresh(),
      child: _OrderTrackingView(orderId: orderId),
    );
  }
}

class _OrderTrackingView extends StatelessWidget {
  final int orderId;

  const _OrderTrackingView({required this.orderId});

  Future<void> _confirmDistribution(BuildContext context) async {
    final cubit = context.read<OrderTrackingCubit>();
    final ok = await cubit.confirmDistribution();
    if (ok && context.mounted) {
      context.push(RouteNames.charityDistributionDataPath(orderId));
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
            'متابعة الطلب',
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Container(
              height: 1.h,
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
        body: BlocConsumer<OrderTrackingCubit, OrderTrackingState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
              context.read<OrderTrackingCubit>().consumeSuccessMessage();
            }
            if (state.actionErrorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionErrorMessage!)),
              );
              context.read<OrderTrackingCubit>().clearActionError();
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.order == null) {
              return const Center(child: LoadingIndicator.fullScreen());
            }
            if (state.isFailure && state.order == null) {
              return AppErrorWidget(
                message: state.errorMessage ?? 'تعذر تحميل الطلب',
                retryLabel: 'إعادة المحاولة',
                onRetry: () => context.read<OrderTrackingCubit>().load(orderId),
              );
            }
            final order = state.order;
            if (order == null) {
              return const AppErrorWidget(message: 'لا توجد بيانات للطلب');
            }

            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () => context.read<OrderTrackingCubit>().refresh(),
              child: _TrackingBody(
                order: order,
                actionInProgress: state.actionInProgress,
                onConfirmPickup: () =>
                    context.read<OrderTrackingCubit>().confirmPickup(),
                onConfirmDistribution: () => _confirmDistribution(context),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TrackingBody extends StatelessWidget {
  final DonationRequest order;
  final OrderTrackingAction? actionInProgress;
  final VoidCallback onConfirmPickup;
  final VoidCallback onConfirmDistribution;

  const _TrackingBody({
    required this.order,
    required this.actionInProgress,
    required this.onConfirmPickup,
    required this.onConfirmDistribution,
  });

  @override
  Widget build(BuildContext context) {
    // Waiting on the donor's own half of the handover — the status stays
    // `accepted` on the wire (see DonationRequest.awaitingCharityConfirmation
    // for the donor-side equivalent).
    final charityConfirmedPickup = order.charityConfirmedAt != null;
    final pickupDone =
        order.status == DonationStatus.pickedUp ||
        order.status == DonationStatus.completed;
    final distributionDone = order.status == DonationStatus.completed;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.all(AppConstants.paddingMD.w),
      children: [
        Text(
          order.title ?? order.foodCategory?.nameAr ?? 'طلب تبرع',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
          ),
        ),
        SizedBox(height: AppConstants.paddingSM.h),
        Text(
          '#ORD-${order.id.toString().padLeft(4, '0')}',
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppConstants.paddingLG.h),

        OrderTrackingStep(
          status: OrderStepStatus.done,
          title: 'قبول الطلب',
          description: 'تم قبول الطلب من قبل المنظمة الخيرية.',
        ),
        OrderTrackingStep(
          status: pickupDone ? OrderStepStatus.done : OrderStepStatus.current,
          title: 'تأكيد أخذ الطلب',
          description: pickupDone
              ? 'تم تأكيد استلام الطعام من نقطة التجمع.'
              : (charityConfirmedPickup
                    ? 'تم تسجيل تأكيدك، بانتظار تأكيد المتبرع.'
                    : 'يرجى تأكيد استلامك للوجبات من نقطة التجمع.'),
          actionLabel: pickupDone
              ? null
              : (charityConfirmedPickup ? null : 'تأكيد الأخذ'),
          onAction: onConfirmPickup,
          isLoading: actionInProgress == OrderTrackingAction.confirmPickup,
        ),
        OrderTrackingStep(
          status: distributionDone
              ? OrderStepStatus.done
              : (pickupDone
                    ? OrderStepStatus.current
                    : OrderStepStatus.upcoming),
          title: 'تأكيد توزيع الطلب',
          description: distributionDone
              ? 'تم تأكيد توزيع الطعام على المستفيدين.'
              : (pickupDone
                    ? 'يرجى تأكيد توزيع الطعام على المستفيدين.'
                    : 'سيتم تفعيل هذه الخطوة بعد تأكيد الأخذ.'),
          actionLabel: distributionDone ? null : 'تأكيد التوزيع',
          onAction: onConfirmDistribution,
          isLoading:
              actionInProgress == OrderTrackingAction.confirmDistribution,
          isLast: true,
        ),

        SizedBox(height: AppConstants.paddingLG.h),
        DonationSummaryCard(donation: order),
        SizedBox(height: AppConstants.paddingLG.h),
      ],
    );
  }
}
