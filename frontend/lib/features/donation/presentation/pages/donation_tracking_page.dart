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
import '../widgets/confirm_pickup_sheet.dart';
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
      create: (_) => sl<DonationDetailsCubit>()..load(donationId)..startAutoRefresh(),
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
    final reasonController = TextEditingController();
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: AppColors.surfaceLight,
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
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: AppConstants.paddingMD.h),
                  TextField(
                    controller: reasonController,
                    maxLength: 255,
                    decoration: const InputDecoration(hintText: 'السبب (اختياري)'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('تراجع'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text('نعم، إلغاء', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ),
        ) ?? false;

    if (confirmed && mounted) {
      final reason = reasonController.text.trim();
      reasonController.dispose();
      await _cubit.cancelDonation(reason: reason.isEmpty ? null : reason);
    } else {
      reasonController.dispose();
    }
  }

  void _maybeShowRatingSheet(DonationRequest donation) {
    if (_ratingSheetShown || donation.charity == null || !donation.canRate) return;
    _ratingSheetShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      CharityRatingSheet.show(context, cubit: _cubit, charity: donation.charity!);
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.brandBeige,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceLight,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            'متابعة الطلب',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.brandGreen,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Container(height: 1.h, color: AppColors.divider.withValues(alpha: 0.6)),
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
            if (donation != null && donation.status == DonationStatus.pickedUp) {
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
              color: AppColors.brandGreen,
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
          onConfirmPickup: () => ConfirmPickupSheet.show(context, cubit: _cubit),
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
            decoration: const BoxDecoration(color: AppColors.brandGreen, shape: BoxShape.circle),
            child: Icon(
              Icons.volunteer_activism_rounded,
              size: 44.r,
              color: Colors.white.withValues(alpha: 0.92),
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
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
        ),
        SizedBox(height: AppConstants.paddingXL.h),
        DonationSummaryCard(donation: donation),
        SizedBox(height: AppConstants.paddingXL.h),
        BlocBuilder<DonationDetailsCubit, DonationDetailsState>(
          buildWhen:
              (previous, current) => previous.actionInProgress != current.actionInProgress,
          builder: (context, state) => SizedBox(
            height: AppConstants.buttonHeight.h,
            child: OutlinedButton.icon(
              onPressed:
                  state.actionInProgress == DonationAction.cancel ? null : () => onCancel(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
                ),
              ),
              icon:
                  state.actionInProgress == DonationAction.cancel
                      ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                        ),
                      )
                      : const Icon(Icons.close_rounded, size: 20),
              label: Text(
                state.actionInProgress == DonationAction.cancel ? 'جارٍ الإلغاء...' : 'إلغاء الطلب',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMD.w,
        vertical: AppConstants.paddingLG.h,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppConstants.paddingMD.w),
          decoration: BoxDecoration(
            color: AppColors.brandGreen,
            borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandGreen.withValues(alpha: 0.25),
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
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, size: 26.r, color: Colors.white),
              ),
              SizedBox(width: AppConstants.paddingMD.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تم قبول طلبك',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'ستتواصل معك الجمعية لاستلام التبرع قريباً',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
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
          _CharityCard(charity: donation.charity!, etaMinutes: donation.etaMinutes),
          SizedBox(height: AppConstants.paddingMD.h),
        ],
        Text(
          'تفاصيل الطلب',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp),
        ),
        SizedBox(height: AppConstants.paddingSM.h),
        DonationSummaryCard(donation: donation),
        SizedBox(height: AppConstants.paddingXL.h),
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
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
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
    final (icon, color, containerColor, title, subtitle) = switch (donation.status) {
      DonationStatus.pickedUp => (
        Icons.check_circle_rounded,
        AppColors.brandGreen,
        AppColors.primaryContainer,
        'تم استلام التبرع بنجاح',
        'شكراً لمساهمتك في إطعام من يحتاج',
      ),
      DonationStatus.completed => (
        Icons.verified_rounded,
        AppColors.brandGreen,
        AppColors.primaryContainer,
        'تم إتمام التبرع',
        'شكراً لمساهمتك في إطعام من يحتاج',
      ),
      DonationStatus.cancelled => (
        Icons.cancel_rounded,
        AppColors.error,
        AppColors.errorContainer,
        'تم إلغاء الطلب',
        donation.cancelReason ?? 'يمكنك إنشاء طلب تبرع جديد في أي وقت',
      ),
      DonationStatus.expired => (
        Icons.timer_off_rounded,
        AppColors.textSecondaryLight,
        AppColors.surfaceVariantLight,
        'انتهت صلاحية الطلب',
        'لم تُستلم التبرعات قبل انتهاء الوقت المحدد',
      ),
      _ => (
        Icons.event_busy_rounded,
        AppColors.error,
        AppColors.errorContainer,
        'لم يتم الحضور',
        'لم تحضر الجمعية لاستلام التبرع',
      ),
    };

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
            decoration: BoxDecoration(color: containerColor, shape: BoxShape.circle),
            child: Icon(icon, size: 42.r, color: color),
          ),
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 17.sp),
        ),
        SizedBox(height: AppConstants.paddingSM.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondaryLight,
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
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.brandGreen),
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
    final rating = donation.rating;

    if (rating != null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppConstants.paddingMD.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < rating.stars ? Icons.star_rounded : Icons.star_outline_rounded,
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
                  color: AppColors.textSecondaryLight,
                  height: 1.6,
                ),
              ),
            ],
            SizedBox(height: AppConstants.paddingSM.h),
            Text(
              'تقييمك للجمعية',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
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
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.brandGreen,
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
    final parts = charity.name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '؟';
    if (parts.length == 1) return parts.first.characters.first;
    return '${parts.first.characters.first}${parts.last.characters.first}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.paddingMD.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                backgroundColor: AppColors.brandGreen,
                foregroundImage:
                    charity.logoUrl != null ? NetworkImage(charity.logoUrl!) : null,
                onForegroundImageError: (_, _) {},
                child: Text(
                  _initials,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
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
                        Icon(Icons.star_rounded, size: 15.r, color: AppColors.warning),
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
                              color: AppColors.textSecondaryLight,
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
          Divider(color: AppColors.divider.withValues(alpha: 0.6), height: 1),
          SizedBox(height: AppConstants.paddingSM.h),
          Row(
            children: [
              Icon(Icons.verified_outlined, size: 16.r, color: AppColors.brandGreen),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'أتمّت ${charity.completedDonationsCount} تبرع',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              Icon(Icons.phone_outlined, size: 16.r, color: AppColors.textSecondaryLight),
              SizedBox(width: 6.w),
              Text(
                charity.phone,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: AppConstants.paddingXS.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 16.r, color: AppColors.textSecondaryLight),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  charity.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
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
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_rounded, size: 18.r, color: AppColors.brandGreen),
                  SizedBox(width: 8.w),
                  Text(
                    'الوصول المتوقع: ${DateFormatter.formatEta(etaMinutes)}',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.brandGreen,
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
