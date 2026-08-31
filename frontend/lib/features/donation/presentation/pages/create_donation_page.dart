import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/base/base_state.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../domain/params/create_donation_params.dart';
import '../bloc/create_donation_cubit.dart';
import '../bloc/create_donation_state.dart';

/// Create Donation Request form (Screen 2) — food details, food state
/// (ready / needs cooking), pickup timeline and pickup location.
class CreateDonationPage extends StatelessWidget {
  const CreateDonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateDonationCubit>()..loadCategories(),
      child: const _CreateDonationView(),
    );
  }
}

class _CreateDonationView extends StatefulWidget {
  const _CreateDonationView();

  @override
  State<_CreateDonationView> createState() => _CreateDonationViewState();
}

class _CreateDonationViewState extends State<_CreateDonationView> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pickupUntilController = TextEditingController();
  final _validUntilController = TextEditingController();

  DateTime? _pickupUntil;
  DateTime? _validUntil;

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _pickupUntilController.dispose();
    _validUntilController.dispose();
    super.dispose();
  }

  // ── Pickers ─────────────────────────────────────────────────────────────────

  Future<DateTime?> _pickDateTime({
    DateTime? initial,
    DateTime? first,
    DateTime? last,
  }) async {
    final now = DateTime.now();
    final effectiveFirst = first ?? now;
    DateTime effectiveInitial = initial ?? effectiveFirst;
    if (effectiveInitial.isBefore(effectiveFirst)) effectiveInitial = effectiveFirst;
    if (last != null && effectiveInitial.isAfter(last)) effectiveInitial = last;

    final date = await showDatePicker(
      context: context,
      initialDate: effectiveInitial,
      firstDate: effectiveFirst,
      lastDate: last ?? now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickPickupUntil() async {
    final picked = await _pickDateTime(
      initial: _pickupUntil,
      first: DateTime.now(),
      last: _validUntil,
    );
    if (picked == null) return;

    setState(() {
      _pickupUntil = picked;
      _pickupUntilController.text = DateFormatter.formatDateTime(picked);
    });
    _formKey.currentState?.validate();
  }

  Future<void> _pickValidUntil() async {
    final picked = await _pickDateTime(
      initial: _validUntil,
      first: _pickupUntil ?? DateTime.now(),
    );
    if (picked == null) return;

    setState(() {
      _validUntil = picked;
      _validUntilController.text = DateFormatter.formatDateTime(picked);
    });
    _formKey.currentState?.validate();
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<CreateDonationCubit>();
    final selectedCategoryId = cubit.state.selectedCategoryId;
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار نوع الطعام أولاً')));
      return;
    }

    await cubit.submit(
      CreateDonationParams(
        foodCategoryId: selectedCategoryId,
        needsCooking: cubit.state.needsCooking,
        quantityDesc: _quantityController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        validUntil: _validUntil!,
        pickupUntil: _pickupUntil!,
        pickupAddress: _addressController.text.trim(),
        contactPhone: _phoneController.text.trim(),
      ),
    );
  }

  // ── Category picker sheet ───────────────────────────────────────────────────

  // ── Validators ──────────────────────────────────────────────────────────────

  String? _validatePickupUntil(String? _) {
    if (_pickupUntil == null) return 'يرجى تحديد آخر وقت للاستلام';
    if (!_pickupUntil!.isAfter(DateTime.now())) return 'يجب أن يكون الوقت بعد الوقت الحالي';
    return null;
  }

  String? _validateValidUntil(String? _) {
    if (_validUntil == null) return 'يرجى تحديد وقت انتهاء الصلاحية';
    if (_pickupUntil != null && _validUntil!.isBefore(_pickupUntil!)) {
      return 'يجب أن يكون بعد آخر وقت للاستلام أو مساوياً له';
    }
    return null;
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
            'طلب تبرع جديد',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.brandGreen,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimaryLight),
            onPressed: () => context.pop(),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Container(height: 1.h, color: AppColors.divider.withValues(alpha: 0.6)),
          ),
        ),
        body: BlocListener<CreateDonationCubit, CreateDonationState>(
          listenWhen:
              (previous, current) =>
                  previous.status != current.status && current.status != BlocStatus.loading,
          listener: (context, state) {
            if (state.status == BlocStatus.success && state.createdDonation != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('تم نشر طلب التبرع بنجاح')));
              context.pushReplacement(RouteNames.donationDetailsPath(state.createdDonation!.id));
            } else if (state.status == BlocStatus.failure && state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMD.w,
                vertical: AppConstants.paddingLG.h,
              ),
              children: [
                const _SectionHeader('تفاصيل الطعام'),
                const _CategoryDropdown(),
                SizedBox(height: AppConstants.paddingMD.h),
                CustomTextField(
                  label: 'الكمية',
                  hint: 'مثال: وجبات تكفي 10 أشخاص',
                  controller: _quantityController,
                  keyboardType: TextInputType.text,
                  validator: requiredFieldValidator(fieldName: 'الكمية'),
                ),
                SizedBox(height: AppConstants.paddingMD.h),
                CustomTextField(
                  label: 'وصف إضافي (اختياري)',
                  hint: 'أي تفاصيل تساعد الجمعية، مثل طريقة التخزين',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
                SizedBox(height: AppConstants.paddingXL.h),

                const _SectionHeader('حالة الطعام'),
                const _FoodStateSelector(),
                SizedBox(height: AppConstants.paddingXL.h),

                const _SectionHeader('التوقيت'),
                _DateTimeField(
                  label: 'آخر وقت للاستلام',
                  hint: 'متى يجب أن تستلم الجمعية التبرع؟',
                  icon: Icons.schedule_rounded,
                  controller: _pickupUntilController,
                  validator: _validatePickupUntil,
                  onTap: _pickPickupUntil,
                ),
                SizedBox(height: AppConstants.paddingMD.h),
                _DateTimeField(
                  label: 'صالح حتى',
                  hint: 'حتى متى يبقى الطعام صالحاً للاستهلاك؟',
                  icon: Icons.event_available_rounded,
                  controller: _validUntilController,
                  validator: _validateValidUntil,
                  onTap: _pickValidUntil,
                ),
                SizedBox(height: AppConstants.paddingXL.h),

                const _SectionHeader('الموقع'),
                CustomTextField(
                  label: 'عنوان الاستلام',
                  hint: 'الحي، الشارع، أقرب معلم',
                  controller: _addressController,
                  maxLines: 2,
                  validator: requiredFieldValidator(fieldName: 'عنوان الاستلام'),
                ),
                SizedBox(height: AppConstants.paddingXL.h),

                const _SectionHeader('التواصل'),
                CustomTextField(
                  label: 'رقم التواصل',
                  hint: 'رقم الهاتف الذي تتواصل معك الجمعية عبره',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  validator: phoneValidator,
                ),
                SizedBox(height: AppConstants.paddingXXL.h),

                BlocBuilder<CreateDonationCubit, CreateDonationState>(
                  buildWhen: (previous, current) => previous.status != current.status,
                  builder: (context, state) => CustomButton(
                    label: 'تأكيد الطلب',
                    onPressed: _submit,
                    isLoading: state.status == BlocStatus.loading,
                  ),
                ),
                SizedBox(height: AppConstants.paddingMD.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.paddingMD.h),
      child: Row(
        children: [
          Container(
            width: 4.r,
            height: 18.r,
            decoration: BoxDecoration(
              color: AppColors.brandGreen,
              borderRadius: BorderRadius.circular(AppConstants.radiusXS.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// Food-category dropdown — mirrors the register page's `DropdownButtonFormField`
/// (account-type field): items load from the API and the selection is mirrored
/// to the cubit, which pre-ticks the cooking state from the category default.
class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateDonationCubit, CreateDonationState>(
      buildWhen:
          (previous, current) =>
              previous.selectedCategoryId != current.selectedCategoryId ||
              previous.categoriesStatus != current.categoriesStatus ||
              previous.categories.length != current.categories.length,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              initialValue: state.selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'نوع الطعام',
                prefixIcon: Icon(Icons.fastfood_outlined),
              ),
              items:
                  state.categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.nameAr),
                    );
                  }).toList(),
              onChanged:
                  state.categoriesStatus == BlocStatus.success
                      ? (id) {
                        final category = state.categories.firstWhere((c) => c.id == id);
                        context.read<CreateDonationCubit>().selectCategory(category);
                      }
                      : null,
              validator: (_) => state.selectedCategoryId == null ? 'يرجى اختيار نوع الطعام' : null,
            ),
            if (state.categoriesStatus == BlocStatus.loading) ...[
              SizedBox(height: AppConstants.paddingSM.h),
              Text(
                'جارٍ تحميل أنواع الطعام...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontSize: 11.sp,
                ),
              ),
            ],
            if (state.categoriesStatus == BlocStatus.failure) ...[
              SizedBox(height: AppConstants.paddingSM.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      state.categoriesErrorMessage ?? 'تعذر تحميل أنواع الطعام',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.read<CreateDonationCubit>().loadCategories(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Ready-to-eat vs needs-cooking choice chips (backend `needs_cooking`).
class _FoodStateSelector extends StatelessWidget {
  const _FoodStateSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateDonationCubit, CreateDonationState>(
      buildWhen: (previous, current) => previous.needsCooking != current.needsCooking,
      builder: (context, state) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _FoodStateChip(
                    label: 'جاهز للأكل',
                    icon: Icons.restaurant_rounded,
                    selected: !state.needsCooking,
                    onTap: () => context.read<CreateDonationCubit>().setNeedsCooking(false),
                  ),
                ),
                SizedBox(width: AppConstants.paddingMD.w),
                Expanded(
                  child: _FoodStateChip(
                    label: 'يحتاج طهي',
                    icon: Icons.local_fire_department_rounded,
                    selected: state.needsCooking,
                    onTap: () => context.read<CreateDonationCubit>().setNeedsCooking(true),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingSM.h),
            Text(
              'يُحدد تلقائياً حسب نوع الطعام ويمكنك تعديله',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
                fontSize: 11.sp,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FoodStateChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FoodStateChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandGreen : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
          border: Border.all(
            color: selected ? AppColors.brandGreen : AppColors.outlineLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.r,
              color: selected ? Colors.white : AppColors.textSecondaryLight,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                color: selected ? Colors.white : AppColors.textSecondaryLight,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only tappable field showing a picked date-time — mirrors the register
/// page's work-start/work-end fields: the controller text is set inside the
/// tap handler's setState, never during build.
class _DateTimeField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final Future<void> Function() onTap;

  const _DateTimeField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.validator,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      prefixIcon: icon,
      readOnly: true,
      showCursor: false,
      onTap: onTap,
      validator: validator,
    );
  }
}
