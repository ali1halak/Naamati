import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/donation_audit_cubit.dart';
import '../bloc/donation_audit_state.dart';

/// Screen 2: Donation Audit Details (تفاصيل التبرع)
///
/// A comprehensive audit view displaying:
/// 1. Order information (معلومات الطلب)
/// 2. Logistics timestamps (التفاصيل اللوجستية)
/// 3. Community impact numbers (الأثر المجتمعي)
/// 4. Charity evaluation action (تقييم الجمعية)
class DonationAuditPage extends StatelessWidget {
  final int donationId;

  const DonationAuditPage({super.key, required this.donationId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DonationAuditCubit>()..loadAudit(donationId),
      child: _DonationAuditView(donationId: donationId),
    );
  }
}

class _DonationAuditView extends StatelessWidget {
  final int donationId;

  const _DonationAuditView({required this.donationId});

  void _showRatingModal(
    BuildContext context,
    DonationAuditCubit cubit,
    String charityName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AuditRatingSheet(
        donationId: donationId,
        charityName: charityName,
        cubit: cubit,
      ),
    );
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
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 24.r,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: Text(
            'تفاصيل التبرع',
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
        body: BlocConsumer<DonationAuditCubit, DonationAuditState>(
          listener: (context, state) {
            if (state.ratingSuccessMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.ratingSuccessMessage!,
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                  backgroundColor: colorScheme.primary,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.audit == null) {
              return const Center(child: LoadingIndicator.fullScreen());
            }

            if (state.isFailure && state.audit == null) {
              return AppErrorWidget(
                message: state.errorMessage ?? 'تعذر تحميل تفاصيل تدقيق التبرع',
                retryLabel: 'إعادة المحاولة',
                onRetry: () =>
                    context.read<DonationAuditCubit>().loadAudit(donationId),
              );
            }

            final audit = state.audit;
            if (audit == null) {
              return const SizedBox.shrink();
            }

            final charityName = audit.logisticsDetails.charityName ?? 'الجمعية';

            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () =>
                  context.read<DonationAuditCubit>().loadAudit(donationId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLG.w,
                  vertical: AppConstants.paddingLG.h,
                ),
                child: Column(
                  children: [
                    // ── Status Badge pill ───────────────────────────────────
                    _StatusBadge(statusLabel: audit.orderInfo.statusLabel),
                    SizedBox(height: 12.h),

                    // ── Main Food Title ─────────────────────────────────────
                    Text(
                      _formatTitle(audit.orderInfo.title),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ── Audit Card Container ────────────────────────────────
                    Container(
                      padding: EdgeInsets.all(AppConstants.paddingLG.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusXL.r,
                        ),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.35),
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.03),
                            blurRadius: 15.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Order Info Section
                          _SectionTitle(title: 'معلومات الطلب'),
                          SizedBox(height: 10.h),
                          _DetailRow(
                            label: 'رقم الطلب',
                            value: audit.orderInfo.orderNumber,
                            isBoldValue: true,
                          ),
                          _DetailRow(
                            label: 'نوع الطعام',
                            value: audit.orderInfo.foodType ?? '—',
                          ),
                          _DetailRow(
                            label: 'حالة الطعام',
                            value: audit.orderInfo.foodCondition ?? '—',
                          ),
                          _DetailRow(
                            label: 'تاريخ الصلاحية',
                            value: audit.orderInfo.expiryDate ?? '—',
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'وصف الطعام',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13.sp,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusMD.r,
                              ),
                              border: Border.all(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.w,
                              ),
                            ),
                            child: Text(
                              (audit.orderInfo.description != null &&
                                      audit.orderInfo.description!
                                          .trim()
                                          .isNotEmpty)
                                  ? audit.orderInfo.description!
                                  : (audit.orderInfo.quantity == null
                                        ? 'لا يوجد وصف'
                                        : 'الكمية التقديرية: ${audit.orderInfo.quantity} شخص'),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: 13.sp,
                                height: 1.4,
                              ),
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // 2. Logistics Section
                          _SectionTitle(title: 'التفاصيل اللوجستية'),
                          SizedBox(height: 10.h),
                          _DetailRow(
                            label: 'اسم الجمعية',
                            value: audit.logisticsDetails.charityName ?? '—',
                            valueColor: colorScheme.primary,
                            isBoldValue: true,
                          ),
                          _DetailRow(
                            label: 'موقع أخذ الطلب',
                            value: audit.logisticsDetails.pickupAddress ?? '—',
                          ),
                          _DetailRow(
                            label: 'وقت إرسال الطلب',
                            value: audit.logisticsDetails.submittedAt ?? '—',
                          ),
                          _DetailRow(
                            label: 'وقت قبول الطلب',
                            value: audit.logisticsDetails.acceptedAt ?? '—',
                          ),
                          _DetailRow(
                            label: 'وقت أخذ الطلب',
                            value: audit.logisticsDetails.pickedUpAt ?? '—',
                          ),

                          SizedBox(height: 24.h),

                          // 3. Social Impact Section
                          _SectionTitle(title: 'الأثر المجتمعي'),
                          SizedBox(height: 10.h),
                          if (audit.socialImpact != null) ...[
                            _DetailRow(
                              label: 'عدد العائلات المستفيدة',
                              value:
                                  '${audit.socialImpact!.beneficiaryFamilies}',
                            ),
                            _DetailRow(
                              label: 'عدد الأفراد المستفيدين',
                              value:
                                  '${audit.socialImpact!.beneficiaryIndividuals}',
                            ),
                            _DetailRow(
                              label: 'منطقة التوزيع',
                              value: audit.socialImpact!.distributionZone,
                            ),
                            _DetailRow(
                              label: 'الملاحظات',
                              value:
                                  (audit.socialImpact!.notes != null &&
                                      audit.socialImpact!.notes!
                                          .trim()
                                          .isNotEmpty)
                                  ? audit.socialImpact!.notes!
                                  : 'لا يوجد',
                            ),
                          ] else ...[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.radiusMD.r,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 18.r,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        'سيظهر تقرير الأثر المجتمعي بعد توثيق الجمعية لعملية التوزيع.',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // ── Bottom Action Button: تقييم الجمعية ─────────────────
                    if (audit.rating != null) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 14.h,
                          horizontal: 16.w,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusLG.r,
                          ),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            width: 1.w,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: AppColors.warning,
                              size: 22.r,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'تم تقييم الجمعية (${audit.rating!.stars}/5 نجوم)',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      CustomButton(
                        label: '★ تقييم الجمعية',
                        // Only ratable from handover onward (backend:
                        // `can_rate_charity`) — disabled while the request is
                        // still pending/accepted instead of letting the tap
                        // fail server-side.
                        onPressed: audit.canRateCharity
                            ? () => _showRatingModal(
                                context,
                                context.read<DonationAuditCubit>(),
                                charityName,
                              )
                            : null,
                      ),
                    ],
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatTitle(String? title) {
    if (title == null || title.isEmpty) {
      return 'تفاصيل التبرع';
    }
    if (title.startsWith('تبرع')) {
      return title;
    }
    return 'تبرع $title';
  }
}

class _StatusBadge extends StatelessWidget {
  final String statusLabel;

  const _StatusBadge({required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusCircular.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 16.r,
            color: colorScheme.primary,
          ),
          SizedBox(width: 6.w),
          Text(
            statusLabel,
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Divider(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
          thickness: 1.h,
          height: 1.h,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBoldValue;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBoldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: AppTextStyles.bodyMedium.copyWith(
                color: valueColor ?? colorScheme.onSurface,
                fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rating bottom sheet for DonationAuditPage
class _AuditRatingSheet extends StatefulWidget {
  final int donationId;
  final String charityName;
  final DonationAuditCubit cubit;

  const _AuditRatingSheet({
    required this.donationId,
    required this.charityName,
    required this.cubit,
  });

  @override
  State<_AuditRatingSheet> createState() => _AuditRatingSheetState();
}

class _AuditRatingSheetState extends State<_AuditRatingSheet> {
  int _stars = 5;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await widget.cubit.rateCharity(
      id: widget.donationId,
      stars: _stars,
      comment: _commentController.text.trim().isNotEmpty
          ? _commentController.text.trim()
          : null,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppConstants.radiusXL.r),
              topRight: Radius.circular(AppConstants.radiusXL.r),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            AppConstants.paddingLG.w,
            AppConstants.paddingMD.h,
            AppConstants.paddingLG.w,
            AppConstants.paddingLG.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular.r,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppConstants.paddingMD.h),
              Text(
                'تقييم الجمعية',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'كيف كانت تجربتك مع ${widget.charityName}؟',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: AppConstants.paddingLG.h),

              // Stars selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final filled = index < _stars;
                  return GestureDetector(
                    onTap: () => setState(() => _stars = index + 1),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 42.r,
                        color: AppColors.warning,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: AppConstants.paddingLG.h),

              // Comment input
              TextField(
                controller: _commentController,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText:
                      'أضف ملاحظاتك أو تعليقك على أداء الجمعية (اختياري)...',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(height: AppConstants.paddingMD.h),

              BlocBuilder<DonationAuditCubit, DonationAuditState>(
                bloc: widget.cubit,
                builder: (context, state) {
                  if (state.ratingErrorMessage != null) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: AppConstants.paddingSM.h,
                      ),
                      child: Text(
                        state.ratingErrorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              BlocBuilder<DonationAuditCubit, DonationAuditState>(
                bloc: widget.cubit,
                builder: (context, state) => CustomButton(
                  label: 'إرسال التقييم',
                  onPressed: _submit,
                  isLoading: state.isSubmittingRating,
                ),
              ),
              SizedBox(height: AppConstants.paddingSM.h),
            ],
          ),
        ),
      ),
    );
  }
}
