import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/location/open_in_maps_button.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/charity_order_audit_cubit.dart';
import '../bloc/charity_order_audit_state.dart';

/// "تفاصيل الطلب" — read-only audit view of one order this charity handled,
/// reached by tapping a card on "الطلبات السابقة". Mirrors the donor-side
/// [DonationAuditPage]'s section layout, grouped by [CharityOrderAudit]'s
/// donor/donation/pickup/distribution shape (backend: `GET
/// /charity/requests/{id}/details`).
class CharityOrderDetailsPage extends StatelessWidget {
  final int orderId;

  const CharityOrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CharityOrderAuditCubit>()..loadAudit(orderId),
      child: _CharityOrderDetailsView(orderId: orderId),
    );
  }
}

class _CharityOrderDetailsView extends StatelessWidget {
  final int orderId;

  const _CharityOrderDetailsView({required this.orderId});

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
                context.go(RouteNames.charityHome);
              }
            },
          ),
          title: Text(
            'تفاصيل الطلب',
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
        body: BlocBuilder<CharityOrderAuditCubit, CharityOrderAuditState>(
          builder: (context, state) {
            if (state.isLoading && state.audit == null) {
              return const Center(child: LoadingIndicator.fullScreen());
            }
            if (state.isFailure && state.audit == null) {
              return AppErrorWidget(
                message: state.errorMessage ?? 'تعذر تحميل تفاصيل الطلب',
                retryLabel: 'إعادة المحاولة',
                onRetry: () =>
                    context.read<CharityOrderAuditCubit>().loadAudit(orderId),
              );
            }

            final audit = state.audit;
            if (audit == null) return const SizedBox.shrink();

            return RefreshIndicator(
              color: colorScheme.primary,
              onRefresh: () =>
                  context.read<CharityOrderAuditCubit>().loadAudit(orderId),
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
                    _StatusBadge(statusLabel: audit.statusLabel),
                    SizedBox(height: 12.h),
                    Text(
                      audit.donation.category ?? 'تفاصيل الطلب',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      audit.orderId,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 20.h),
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
                          // ── معلومات الطلب ──────────────────────────────
                          const _SectionTitle(title: 'معلومات الطلب'),
                          SizedBox(height: 10.h),
                          _DetailRow(
                            label: 'حالة الطعام',
                            value: audit.donation.foodCondition ?? '—',
                          ),
                          _DetailRow(
                            label: 'الكمية التقديرية',
                            value: audit.donation.quantity != null
                                ? '${audit.donation.quantity} شخص'
                                : '—',
                          ),
                          _DetailRow(
                            label: 'صلاحية الطعام حتى',
                            value: audit.donation.expiryDate ?? '—',
                          ),
                          _DetailRow(
                            label: 'وصف الطعام',
                            value:
                                (audit.donation.description ?? '')
                                    .trim()
                                    .isNotEmpty
                                ? audit.donation.description!
                                : 'لا يوجد',
                          ),
                          SizedBox(height: 24.h),

                          // ── بيانات المتبرع ─────────────────────────────
                          const _SectionTitle(title: 'بيانات المتبرع'),
                          SizedBox(height: 10.h),
                          _DetailRow(
                            label: 'الاسم',
                            value: audit.donor.name ?? '—',
                            isBoldValue: true,
                          ),
                          _DetailRow(
                            label: 'هاتف التواصل',
                            value: audit.donor.phone ?? '—',
                          ),
                          SizedBox(height: 24.h),

                          // ── تفاصيل الاستلام ────────────────────────────
                          const _SectionTitle(title: 'تفاصيل الاستلام'),
                          SizedBox(height: 10.h),
                          _DetailRow(
                            label: 'موقع الاستلام',
                            value: audit.pickup.location ?? '—',
                          ),
                          if (audit.pickup.latitude != null &&
                              audit.pickup.longitude != null)
                            Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: OpenInMapsButton(
                                  latitude: audit.pickup.latitude,
                                  longitude: audit.pickup.longitude,
                                ),
                              ),
                            ),
                          _DetailRow(
                            label: 'وقت القبول',
                            value: audit.pickup.acceptedAt ?? '—',
                          ),
                          _DetailRow(
                            label: 'الموعد النهائي للاستلام',
                            value: audit.pickup.deadline ?? '—',
                          ),
                          _DetailRow(
                            label: 'وقت الاستلام الفعلي',
                            value: audit.pickup.actualPickupAt ?? 'لم يتم بعد',
                          ),
                          if ((audit.pickup.notes ?? '').trim().isNotEmpty)
                            _DetailRow(
                              label: 'ملاحظات الوصول',
                              value: audit.pickup.notes!,
                            ),
                          SizedBox(height: 24.h),

                          // ── تفاصيل التوزيع ─────────────────────────────
                          const _SectionTitle(title: 'تفاصيل التوزيع'),
                          SizedBox(height: 10.h),
                          if (audit.distribution != null) ...[
                            _DetailRow(
                              label: 'عدد العائلات المستفيدة',
                              value:
                                  '${audit.distribution!.beneficiaryFamilies}',
                            ),
                            _DetailRow(
                              label: 'عدد الأفراد المستفيدين',
                              value:
                                  '${audit.distribution!.beneficiaryIndividuals}',
                            ),
                            _DetailRow(
                              label: 'منطقة التوزيع',
                              value: audit.distribution!.distributionZone,
                            ),
                            _DetailRow(
                              label: 'الملاحظات',
                              value:
                                  (audit.distribution!.notes ?? '')
                                      .trim()
                                      .isNotEmpty
                                  ? audit.distribution!.notes!
                                  : 'لا يوجد',
                            ),
                          ] else
                            Container(
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
                                      'لم تُسجل بيانات التوزيع بعد.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if ((audit.cancelReason ?? '').trim().isNotEmpty) ...[
                            SizedBox(height: 24.h),
                            const _SectionTitle(title: 'سبب الإلغاء'),
                            SizedBox(height: 10.h),
                            Text(
                              audit.cancelReason!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: AppConstants.paddingLG.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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
      child: Text(
        statusLabel,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: 13.sp,
        ),
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
  final bool isBoldValue;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBoldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface,
                fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
