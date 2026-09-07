import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/charity_profile.dart';
import '../../domain/entities/donation_request.dart';
import '../../domain/entities/donation_status.dart';
import '../bloc/donation_details_cubit.dart';
import '../bloc/donation_details_state.dart';
import '../widgets/charity_rating_sheet.dart';
import '../widgets/donation_summary_card.dart';

/// Donation tracking screen — combines Screen 3 (waiting for acceptance),
/// Screen 4 (accepted & details) and the post-delivery / terminal states.
///
/// The status auto-refreshes every 15s while the donation is active so the
/// donor sees the `pending → accepted` transition without pulling to refresh.
class DonationTrackingPage extends StatelessWidget {
  final int donationId;

  const DonationTrackingPage({super.key, required this.donationId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DonationDetailsCubit>()
        ..load(donationId)
        ..startAutoRefresh(),
      child: _TrackingView(donationId: donationId),
    );
  }
}

class _TrackingView extends StatefulWidget {
  final int donationId;

  const _TrackingView({required this.donationId});

  @override
  State<_TrackingView> createState() => _TrackingViewState();
}

class _TrackingViewState extends State<_TrackingView> {
  bool _ratingSheetShown = false;

  DonationDetailsCubit get _cubit => context.read<DonationDetailsCubit>();

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _showCancelDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const _CancelDialog(),
    );

    if (result != null && mounted) {
      await _cubit.cancelDonation(reason: result.isEmpty ? null : result);
    }
  }

  /// Two-sided handover: the donor confirms, then the charity does the same
  /// from its own app. No code entry — the pairing is the request itself.
  Future<void> _confirmHandoverDialog(DonationRequest donation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
          ),
          title: Text('تم التسليم؟', style: AppTextStyles.titleMedium),
          content: Text(
            'هل سلّمت الطعام إلى ممثل الجمعية؟ سيصبح التسليم مؤكداً بعد أن '
            'تؤكد الجمعية أيضاً من تطبيقها.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('تراجع'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('نعم، أكّد التسليم'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await _cubit.confirmPickup();
    }
  }

  void _maybeShowRatingSheet(DonationRequest donation) {
    if (_ratingSheetShown || donation.charity == null || !donation.canRate) {
      return;
    }
    _ratingSheetShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      CharityRatingSheet.show(
        context,
        cubit: _cubit,
        charity: donation.charity!,
      );
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────

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
        body: BlocConsumer<DonationDetailsCubit, DonationDetailsState>(
          listener: (context, state) {
            // Snackbars for one-shot success messages (cancel/confirm/rate).
            if (state.successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
              _cubit.consumeSuccessMessage();
              return;
            }

            // Cancel failures surface as a snackbar (the dialog is already
            // closed); rating/confirm errors are shown inline in their sheets.
            final donation = state.donation;
            if (donation != null &&
                donation.status == DonationStatus.pickedUp) {
              _maybeShowRatingSheet(donation);
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: LoadingIndicator.fullScreen());
            }
            if (state.isFailure) {
              return AppErrorWidget(
                message: state.errorMessage ?? 'تعذر تحميل الطلب',
                retryLabel: 'إعادة المحاولة',
                onRetry: () => _cubit.load(widget.donationId),
              );
            }
            final donation = state.donation;
            if (donation == null) {
              return const AppErrorWidget(message: 'لا توجد بيانات للطلب');
            }

            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: _cubit.refresh,
              child: _buildContent(donation),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(DonationRequest donation) {
    _maybeShowRatingSheet(donation);

    switch (donation.status) {
      case DonationStatus.pending:
        return _PendingView(donation: donation, onCancel: _showCancelDialog);
      case DonationStatus.accepted:
        return _AcceptedView(
          donation: donation,
          onConfirmPickup: () => _confirmHandoverDialog(donation),
          onCancel: _showCancelDialog,
        );
      default:
        return _FinishedView(donation: donation);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 3 — Waiting for acceptance
// ─────────────────────────────────────────────────────────────────────────────

class _PendingView extends StatelessWidget {
  final DonationRequest donation;
  final Future<void> Function() onCancel;

  const _PendingView({required this.donation, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMD.w,
        vertical: AppConstants.paddingLG.h,
      ),
      children: [
        SizedBox(height: AppConstants.paddingXL.h),
        Center(
          child: Container(
            width: 96.r,
            height: 96.r,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.volunteer_activism_rounded,
              size: 44.r,
              color: colorScheme.onPrimary.withValues(alpha: 0.92),
            ),
          ),
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        Text(
          'بانتظار قبول إحدى الجمعيات لطلبك...',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            height: 1.5,
          ),
        ),
        SizedBox(height: AppConstants.paddingSM.h),
        Text(
          'سيتم تحديث الحالة تلقائياً فور قبول الطلب',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppConstants.paddingXL.h),
        // Primary exit right under the status: after posting, leaving is the
        // natural next step — cancel stays far below and behind its
        // confirmation dialog, so it can't be tapped by mistake.
        CustomButton(
          label: 'العودة للرئيسية',
          leadingIcon: const Icon(Icons.home_rounded),
          onPressed: () => context.go(RouteNames.home),
        ),
        SizedBox(height: AppConstants.paddingXL.h),
        DonationSummaryCard(donation: donation),
        SizedBox(height: AppConstants.paddingXL.h),
        // Pending requests stay editable right from the tracking screen.
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    context.push(RouteNames.donationEdit, extra: donation),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMD.r,
                    ),
                  ),
                ),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: Text(
                  'تعديل',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppConstants.paddingMD.w),
            Expanded(
              child: BlocBuilder<DonationDetailsCubit, DonationDetailsState>(
                buildWhen: (previous, current) =>
                    previous.actionInProgress != current.actionInProgress,
                builder: (context, state) => OutlinedButton.icon(
                  onPressed: state.actionInProgress == DonationAction.cancel
                      ? null
                      : () => onCancel(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(
                      color: colorScheme.error.withValues(alpha: 0.5),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusMD.r,
                      ),
                    ),
                  ),
                  icon: state.actionInProgress == DonationAction.cancel
                      ? SizedBox(
                          height: 18.h,
                          width: 18.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.error,
                          ),
                        )
                      : const Icon(Icons.close_rounded, size: 18),
                  label: Text(
                    state.actionInProgress == DonationAction.cancel
                        ? 'جارٍ الإلغاء...'
                        : 'إلغاء',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.paddingLG.h),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen 4 — Order accepted & details
// ─────────────────────────────────────────────────────────────────────────────

class _AcceptedView extends StatelessWidget {
  final DonationRequest donation;
  final VoidCallback onConfirmPickup;
  final Future<void> Function() onCancel;

  const _AcceptedView({
    required this.donation,
    required this.onConfirmPickup,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMD.w,
        vertical: AppConstants.paddingLG.h,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppConstants.paddingMD.w),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.25),
                blurRadius: 16.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: onPrimary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, size: 26.r, color: onPrimary),
              ),
              SizedBox(width: AppConstants.paddingMD.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تم قبول طلبك',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'ستتواصل معك الجمعية لاستلام التبرع قريباً',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: onPrimary.withValues(alpha: 0.8),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppConstants.paddingMD.h),
        if (donation.charity != null) ...[
          _CharityCard(
            charity: donation.charity!,
            etaMinutes: donation.etaMinutes,
          ),
          SizedBox(height: AppConstants.paddingMD.h),
        ],
        Text(
          'تفاصيل الطلب',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        ),
        SizedBox(height: AppConstants.paddingSM.h),
        DonationSummaryCard(donation: donation),
        SizedBox(height: AppConstants.paddingXL.h),
        // Two-sided handover: once the donor pressed, we show what we are
        // waiting for instead of the button.
        if (donation.awaitingCharityConfirmation) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppConstants.paddingMD.w),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  size: 22.r,
                  color: colorScheme.onSecondaryContainer,
                ),
                SizedBox(width: AppConstants.paddingMD.w),
                Expanded(
                  child: Text(
                    'أكّدت التسليم — بانتظار أن تؤكد الجمعية من تطبيقها ليكتمل التسليم',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.paddingXL.h),
        ] else
          CustomButton(
            label: 'تم التسليم',
            leadingIcon: const Icon(Icons.check_circle_outline_rounded),
            onPressed: onConfirmPickup,
          ),
        SizedBox(height: AppConstants.paddingSM.h),
        Center(
          child: TextButton(
            onPressed: onCancel,
            child: Text(
              'إلغاء الطلب',
              style: AppTextStyles.labelLarge.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ),
        SizedBox(height: AppConstants.paddingLG.h),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Post-delivery & terminal states
// ─────────────────────────────────────────────────────────────────────────────

class _FinishedView extends StatelessWidget {
  final DonationRequest donation;

  const _FinishedView({required this.donation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (
      icon,
      color,
      containerColor,
      title,
      subtitle,
    ) = switch (donation.status) {
      DonationStatus.pickedUp => (
        Icons.check_circle_rounded,
        colorScheme.primary,
        colorScheme.primaryContainer,
        'تم استلام التبرع بنجاح',
        'شكراً لمساهمتك في إطعام من يحتاج',
      ),
      DonationStatus.completed => (
        Icons.verified_rounded,
        colorScheme.primary,
        colorScheme.primaryContainer,
        'تم إتمام التبرع',
        'شكراً لمساهمتك في إطعام من يحتاج',
      ),
      DonationStatus.cancelled => (
        Icons.cancel_rounded,
        colorScheme.error,
        colorScheme.errorContainer,
        'تم إلغاء الطلب',
        donation.cancelReason ?? 'يمكنك إنشاء طلب تبرع جديد في أي وقت',
      ),
      DonationStatus.expired => (
        Icons.timer_off_rounded,
        colorScheme.onSurfaceVariant,
        colorScheme.surfaceContainerHighest,
        'انتهت صلاحية الطلب',
        'لم تُستلم التبرعات قبل انتهاء الوقت المحدد',
      ),
      _ => (
        Icons.event_busy_rounded,
        colorScheme.error,
        colorScheme.errorContainer,
        'لم يتم الحضور',
        'لم تحضر الجمعية لاستلام التبرع',
      ),
    };

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMD.w,
        vertical: AppConstants.paddingLG.h,
      ),
      children: [
        SizedBox(height: AppConstants.paddingXL.h),
        Center(
          child: Container(
            width: 88.r,
            height: 88.r,
            decoration: BoxDecoration(
              color: containerColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 42.r, color: color),
          ),
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
        SizedBox(height: AppConstants.paddingSM.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        SizedBox(height: AppConstants.paddingXL.h),
        if (donation.charity != null) ...[
          _CharityCard(charity: donation.charity!, etaMinutes: null),
          SizedBox(height: AppConstants.paddingMD.h),
        ],
        DonationSummaryCard(donation: donation),
        SizedBox(height: AppConstants.paddingXL.h),
        _RatingSection(donation: donation),
        SizedBox(height: AppConstants.paddingLG.h),
        Center(
          child: TextButton(
            onPressed: () => context.go(RouteNames.home),
            child: Text(
              'العودة للرئيسية',
              style: AppTextStyles.labelLarge.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
        SizedBox(height: AppConstants.paddingLG.h),
      ],
    );
  }
}

/// Submitted-rating display or the "rate charity" CTA (when eligible).
class _RatingSection extends StatelessWidget {
  final DonationRequest donation;

  const _RatingSection({required this.donation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rating = donation.rating;

    if (rating != null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppConstants.paddingMD.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < rating.stars
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 28.r,
                  color: AppColors.warning,
                );
              }),
            ),
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              SizedBox(height: AppConstants.paddingSM.h),
              Text(
                rating.comment!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ],
            SizedBox(height: AppConstants.paddingSM.h),
            Text(
              'تقييمك للجمعية',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      );
    }

    if (!donation.canRate) return const SizedBox.shrink();

    return CustomButton(
      label: 'تقييم الجمعية',
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.primary,
      leadingIcon: const Icon(Icons.star_rounded, color: AppColors.warning),
      onPressed: () => CharityRatingSheet.show(
        context,
        cubit: context.read<DonationDetailsCubit>(),
        charity: donation.charity!,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Charity profile card (Screen 4)
// ─────────────────────────────────────────────────────────────────────────────

class _CharityCard extends StatelessWidget {
  final CharityProfile charity;

  /// ETA shown only while the pickup is on its way (accepted state).
  final int? etaMinutes;

  const _CharityCard({required this.charity, required this.etaMinutes});

  String get _initials {
    final parts = charity.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '؟';
    if (parts.length == 1) return parts.first.characters.first;
    return '${parts.first.characters.first}${parts.last.characters.first}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.paddingMD.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: colorScheme.primary,
                foregroundImage: charity.logoUrl != null
                    ? NetworkImage(charity.logoUrl!)
                    : null,
                onForegroundImageError: charity.logoUrl != null
                    ? (_, _) {}
                    : null,
                child: Text(
                  _initials,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              SizedBox(width: AppConstants.paddingMD.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      charity.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 15.r,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            charity.ratingAvg != null
                                ? '${charity.ratingAvg!.toStringAsFixed(1)} '
                                      '(${charity.ratingsCount} تقييم)'
                                : 'لا تقييمات بعد',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.paddingSM.h),
          Divider(color: colorScheme.outline.withValues(alpha: 0.3), height: 1),
          SizedBox(height: AppConstants.paddingSM.h),
          Row(
            children: [
              Icon(
                Icons.verified_outlined,
                size: 16.r,
                color: colorScheme.primary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'أتمّت ${charity.completedDonationsCount} تبرع',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              Icon(
                Icons.phone_outlined,
                size: 16.r,
                color: colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 6.w),
              Text(
                charity.phone,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.paddingXS.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16.r,
                color: colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  charity.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
          if (etaMinutes != null) ...[
            SizedBox(height: AppConstants.paddingSM.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_rounded,
                    size: 18.r,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'الوصول المتوقع: ${DateFormatter.formatEta(etaMinutes)}',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
