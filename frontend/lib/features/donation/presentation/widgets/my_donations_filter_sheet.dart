import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/food_category.dart';
import '../../domain/entities/my_donations_filter.dart';
import '../../domain/usecases/get_food_categories_usecase.dart';

/// Opens the advanced "تبرعاتي" filter bottom sheet.
///
/// Returns the selected [MyDonationsFilter] when the user taps "عرض النتائج"
/// (or the cleared selection via "مسح الكل"), and null when dismissed.
Future<MyDonationsFilter?> showMyDonationsFilterSheet(
  BuildContext context, {
  required MyDonationsFilter current,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return showModalBottomSheet<MyDonationsFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: _FilterSheet(initial: current),
    ),
  );
}

/// How the food-cooking filter is set in the sheet.
enum _FoodState { any, needsCooking, ready }

class _FilterSheet extends StatefulWidget {
  final MyDonationsFilter initial;

  const _FilterSheet({required this.initial});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late MyDonationsFilter _draft;
  late _FoodState _foodState;

  Future<List<FoodCategory>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _foodState = switch (widget.initial.needsCooking) {
      true => _FoodState.needsCooking,
      false => _FoodState.ready,
      null => _FoodState.any,
    };
    _categoriesFuture = sl<GetFoodCategoriesUseCase>()(
      NoParams(),
    ).then((either) => either.fold((_) => <FoodCategory>[], (list) => list));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 12.h,
          bottom: 16.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle + title + clear ───────────────────────────────
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'تصفية التبرعات',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                if (_draft.hasAdvancedFilters)
                  TextButton(
                    onPressed: () => setState(() {
                      // Clears the advanced filters only — search text and
                      // status are preserved.
                      _draft = MyDonationsFilter(
                        query: _draft.query,
                        status: _draft.status,
                      );
                      _foodState = _FoodState.any;
                    }),
                    child: Text(
                      'مسح',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: colorScheme.secondary,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('نوع الطعام'),
                    _buildCategoryChips(),
                    SizedBox(height: 16.h),
                    _SectionTitle('حالة الطعام'),
                    _buildFoodStateChips(),
                    SizedBox(height: 16.h),
                    _SectionTitle('الفترة'),
                    _buildDateRange(),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_draft),
                child: Text(
                  'عرض النتائج',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 15.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sections ────────────────────────────────────────────────────────────────

  Widget _buildCategoryChips() {
    return FutureBuilder<List<FoodCategory>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: SizedBox(
                width: 22.r,
                height: 22.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return Text(
            'لا توجد أنواع طعام متاحة حالياً',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }
        return Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final category in categories)
              _ChoiceChip(
                label: category.nameAr,
                selected: _draft.categoryId == category.id,
                onTap: () => setState(() {
                  _draft = MyDonationsFilter(
                    query: _draft.query,
                    status: _draft.status,
                    categoryId: _draft.categoryId == category.id
                        ? null
                        : category.id,
                    needsCooking: _draft.needsCooking,
                    fromDate: _draft.fromDate,
                    toDate: _draft.toDate,
                  );
                }),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFoodStateChips() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _ChoiceChip(
          label: 'الكل',
          selected: _foodState == _FoodState.any,
          onTap: () => setState(() {
            _foodState = _FoodState.any;
            _draft = _withFoodState(null);
          }),
        ),
        _ChoiceChip(
          label: 'يحتاج طبخاً',
          selected: _foodState == _FoodState.needsCooking,
          onTap: () => setState(() {
            _foodState = _FoodState.needsCooking;
            _draft = _withFoodState(true);
          }),
        ),
        _ChoiceChip(
          label: 'جاهز للتقديم',
          selected: _foodState == _FoodState.ready,
          onTap: () => setState(() {
            _foodState = _FoodState.ready;
            _draft = _withFoodState(false);
          }),
        ),
      ],
    );
  }

  MyDonationsFilter _withFoodState(bool? needsCooking) => MyDonationsFilter(
    query: _draft.query,
    status: _draft.status,
    categoryId: _draft.categoryId,
    needsCooking: needsCooking,
    fromDate: _draft.fromDate,
    toDate: _draft.toDate,
  );

  Widget _buildDateRange() {
    return Row(
      children: [
        Expanded(
          child: _DateField(
            label: 'من تاريخ',
            value: _draft.fromDate,
            onChanged: (date) => setState(() {
              var to = _draft.toDate;
              if (date != null && to != null && to.isBefore(date)) {
                to = date; // keep the range valid.
              }
              _draft = MyDonationsFilter(
                query: _draft.query,
                status: _draft.status,
                categoryId: _draft.categoryId,
                needsCooking: _draft.needsCooking,
                fromDate: date,
                toDate: to,
              );
            }),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            '—',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: _DateField(
            label: 'إلى تاريخ',
            value: _draft.toDate,
            onChanged: (date) => setState(() {
              var from = _draft.fromDate;
              if (date != null && from != null && from.isAfter(date)) {
                from = date; // keep the range valid.
              }
              _draft = MyDonationsFilter(
                query: _draft.query,
                status: _draft.status,
                categoryId: _draft.categoryId,
                needsCooking: _draft.needsCooking,
                fromDate: from,
                toDate: date,
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Small building blocks ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        text,
        style: AppTextStyles.titleSmall.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: selected
                  ? BorderSide(color: colorScheme.primary, width: 1.2)
                  : BorderSide.none,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 12.sp,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Date picker field showing a formatted value or its hint.
class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;

  /// Called with the picked date, or null after clearing.
  final ValueChanged<DateTime?> onChanged;

  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? today,
      firstDate: DateTime(2024),
      lastDate: today.add(const Duration(days: 365)),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: value != null ? colorScheme.primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16.r,
              color: value != null
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                value != null
                    ? '${value!.year}/${value!.month}/${value!.day}'
                    : label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.sp,
                  color: value != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(
                  Icons.close_rounded,
                  size: 16.r,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
