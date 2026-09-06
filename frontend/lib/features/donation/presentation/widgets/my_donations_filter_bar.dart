import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/donation_status.dart';
import '../../domain/entities/my_donations_filter.dart';
import 'donation_status_style.dart';
import 'my_donations_filter_sheet.dart';

/// Horizontal row of status filter chips ("الكل" + every lifecycle status).
///
/// Lives under the search row; the advanced-filters button
/// ([MyDonationsFilterButton]) is composed separately at the search row's end.
///
/// A selected status chip is tinted with the exact same background/foreground
/// pair its card badge uses from [kDonationStatusStyles], so the top filters
/// and the list cards always read as one consistent color system.
class MyDonationsStatusChips extends StatelessWidget {
  final MyDonationsFilter filter;

  /// Called with the new selection whenever a chip is toggled.
  final ValueChanged<MyDonationsFilter> onFilterChanged;

  const MyDonationsStatusChips({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        children: [
          _FilterChip(
            label: 'الكل',
            selected: filter.status == null,
            onTap: () => onFilterChanged(_withStatus(null)),
          ),
          for (final status in DonationStatus.values) ...[
            SizedBox(width: 8.w),
            _FilterChip(
              label: status.labelAr,
              dotColor: kDonationStatusStyles[status]!.foreground,
              selectedStyle: kDonationStatusStyles[status],
              selected: filter.status == status,
              onTap: () => onFilterChanged(
                _withStatus(filter.status == status ? null : status),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Built explicitly — not via copyWith — because clearing a dimension
  // (e.g. "الكل" → status: null) must actually null it out.
  MyDonationsFilter _withStatus(DonationStatus? status) => MyDonationsFilter(
    query: filter.query,
    status: status,
    categoryId: filter.categoryId,
    needsCooking: filter.needsCooking,
    fromDate: filter.fromDate,
    toDate: filter.toDate,
  );
}

/// Round [Icons.tune_rounded] button that opens the advanced filter sheet
/// (category / cooking state / date range). Shows a gold badge dot while any
/// advanced filter is active.
class MyDonationsFilterButton extends StatelessWidget {
  final MyDonationsFilter filter;
  final ValueChanged<MyDonationsFilter> onFilterChanged;

  const MyDonationsFilterButton({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  Future<void> _openSheet(BuildContext context) async {
    final result = await showMyDonationsFilterSheet(context, current: filter);
    if (result != null) {
      onFilterChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasAdvanced = filter.hasAdvancedFilters;

    return Tooltip(
      message: 'فلاتر متقدمة',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: hasAdvanced ? colorScheme.primary : colorScheme.surface,
            shape: CircleBorder(
              side: hasAdvanced
                  ? BorderSide.none
                  : BorderSide(color: colorScheme.outline),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _openSheet(context),
              child: Padding(
                // Sized so the circle matches the search field's height
                // (~46) it sits next to.
                padding: EdgeInsets.all(12.r),
                child: Icon(
                  Icons.tune_rounded,
                  size: 22.r,
                  color: hasAdvanced
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (hasAdvanced)
            Positioned(
              top: -2.r,
              right: -2.r,
              child: Container(
                width: 10.r,
                height: 10.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pill chip for one filter option.
///
/// When [selectedStyle] is provided (status chips), the selected state is
/// filled with that status's badge colors so it mirrors the cards below.
/// Without it ("الكل"), the selected state falls back to the brand green.
class _FilterChip extends StatelessWidget {
  final String label;
  final Color? dotColor;
  final ({Color foreground, Color background})? selectedStyle;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dotColor,
    this.selectedStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // The "الكل" fallback fills with the brand primary; status chips fill
    // with their own semantic badge pair from [selectedStyle].
    final foreground = selected
        ? (selectedStyle?.foreground ?? colorScheme.onPrimary)
        : colorScheme.onSurfaceVariant;
    final background = selected
        ? (selectedStyle?.background ?? colorScheme.primary)
        : colorScheme.surface;
    final borderColor = selected && selectedStyle != null
        ? selectedStyle!.foreground.withValues(alpha: 0.25)
        : colorScheme.outline;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
              side: BorderSide(color: borderColor),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? foreground : dotColor,
                  ),
                ),
                SizedBox(width: 6.w),
              ],
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
