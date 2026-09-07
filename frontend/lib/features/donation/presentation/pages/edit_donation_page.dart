import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/base/base_state.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../domain/entities/donation_request.dart';
import '../../domain/entities/donation_status.dart';
import '../../domain/params/create_donation_params.dart';
import '../bloc/create_donation_cubit.dart';
import '../bloc/create_donation_state.dart';

/// Edit Donation Request — the same authored fields as the create form,
/// pre-filled, for a request still in `pending`. The backend refuses edits
/// once a charity has accepted; this page is only ever opened for pending
/// requests anyway.
class EditDonationPage extends StatelessWidget {
  final DonationRequest donation;

  const EditDonationPage({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    // Belt-and-suspenders: entry points already gate this to pending requests
    // and the backend refuses the update anyway — this only stops an outdated
    // navigation (e.g. a stale list) from opening an editable form.
    if (donation.status != DonationStatus.pending) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
          body: Center(
            child: AppErrorWidget(
              message: 'لا يمكن تعديل الطلب — التعديل متاح فقط للطلبات قيد الانتظار',
              retryLabel: 'رجوع',
              onRetry: () => context.pop(),
            ),
          ),
        ),
      );
    }
    return BlocProvider(
      create: (_) => sl<CreateDonationCubit>()..loadCategories(),
      child: _EditDonationView(donation: donation),
    );
  }
}

class _EditDonationView extends StatefulWidget {
  final DonationRequest donation;

  const _EditDonationView({required this.donation});

  @override
  State<_EditDonationView> createState() => _EditDonationViewState();
}

class _EditDonationViewState extends State<_EditDonationView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _customCategoryController;
  late final TextEditingController _addressController;
  late final TextEditingController _pickupNotesController;
  late final TextEditingController _phoneController;
  late final TextEditingController _pickupUntilController;
  late final TextEditingController _validUntilController;

  DateTime? _pickupUntil;
  DateTime? _validUntil;
  bool _initialised = false;

  // Photo editing: photos already on the server (urls parallel their ids) plus
  // newly picked files. Removing an existing photo only records its id — the
  // deletion itself happens when the update succeeds.
  late final List<String> _existingImageUrls;
  late final List<int> _existingImageIds;
  final List<int> _removedImageIds = [];
  final List<File> _newImages = [];

  static const _maxImages = 4;

  @override
  void initState() {
    super.initState();
    final d = widget.donation;
    _quantityController = TextEditingController(text: d.quantityDesc);
    _descriptionController = TextEditingController(text: d.description ?? '');
    _customCategoryController = TextEditingController();
    _addressController = TextEditingController(text: d.pickupAddress);
    _pickupNotesController = TextEditingController(text: d.pickupNotes ?? '');
    _phoneController = TextEditingController(text: d.contactPhone);
    _pickupUntil = d.pickupUntil;
    _validUntil = d.validUntil;
    _pickupUntilController =
        TextEditingController(text: DateFormatter.formatDateTime(d.pickupUntil));
    _validUntilController =
        TextEditingController(text: DateFormatter.formatDateTime(d.validUntil));
    _existingImageUrls = List.of(d.images);
    _existingImageIds = List.of(d.imageIds);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    _addressController.dispose();
    _pickupNotesController.dispose();
    _phoneController.dispose();
    _pickupUntilController.dispose();
    _validUntilController.dispose();
    super.dispose();
  }

  /// Selects the request's category in the cubit once categories load —
  /// also restores a custom name that came with the request.
  void _syncSelection(CreateDonationState state) {
    if (_initialised) return;
    final category = state.categories
        .where((c) => c.id == widget.donation.foodCategory?.id)
        .firstOrNull;
    if (category == null) return;

    _initialised = true;
    final customName =
        widget.donation.customCategory ?? widget.donation.title ?? '';
    // Deferred: emitting or writing controller text during build throws.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<CreateDonationCubit>();
      cubit.selectCategory(category);
      // Under "غير ذلك" the donor picked the cooking state themselves —
      // restore it; any other category re-derives it from its default.
      if (category.requiresCustomName) {
        cubit.setNeedsCooking(widget.donation.needsCooking);
        _customCategoryController.text = customName;
      }
    });
  }

  Future<void> _pickImages() async {
    final remaining = _maxImages - _existingImageUrls.length - _newImages.length;
    if (remaining <= 0) return;

    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (picked.isEmpty || !mounted) return;

    setState(() {
      _newImages.addAll(picked.take(remaining).map((x) => File(x.path)));
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _removedImageIds.add(_existingImageIds[index]);
      _existingImageIds.removeAt(index);
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() => _newImages.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<CreateDonationCubit>();
    final selectedCategoryId = cubit.state.selectedCategoryId;
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار نوع الطعام أولاً')),
      );
      return;
    }

    final requiresCustomName =
        cubit.state.selectedCategory?.requiresCustomName ?? false;
    final customCategory = _customCategoryController.text.trim();
    if (requiresCustomName && customCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى توضيح نوع الطعام عند اختيار "غير ذلك"'),
        ),
      );
      return;
    }

    await cubit.submitUpdate(
      widget.donation.id,
      CreateDonationParams(
        foodCategoryId: selectedCategoryId,
        needsCooking: cubit.state.needsCooking,
        quantityDesc: _quantityController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        customCategory: customCategory.isEmpty ? null : customCategory,
        validUntil: _validUntil!,
        pickupUntil: _pickupUntil!,
        pickupAddress: _addressController.text.trim(),
        pickupNotes: _pickupNotesController.text.trim().isEmpty
            ? null
            : _pickupNotesController.text.trim(),
        images: _newImages,
        removedImageIds: _removedImageIds,
        contactPhone: _phoneController.text.trim(),
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
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            'تعديل الطلب',
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.h),
            child: Container(
              height: 1.h,
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
        body: BlocConsumer<CreateDonationCubit, CreateDonationState>(
          listener: (context, state) {
            if (state.status == BlocStatus.failure &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
            if (state.status == BlocStatus.success &&
                state.createdDonation != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ التعديلات بنجاح')),
              );
              context.pop();
            }
          },
          builder: (context, state) {
            _syncSelection(state);

            return Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMD.w,
                  vertical: AppConstants.paddingLG.h,
                ),
                children: [
                  _SectionHeader('تفاصيل الطعام'),
                  _CategoryDropdown(state: state),
                  if (state.selectedCategory?.requiresCustomName ?? false)
                    Padding(
                      padding: EdgeInsets.only(top: AppConstants.paddingMD.h),
                      child: CustomTextField(
                        label: 'ما هو الصنف؟',
                        hint: 'اكتب نوع الطعام بدقة، مثال: مربى منزلي',
                        controller: _customCategoryController,
                        isRequired: true,
                        validator: requiredFieldValidator(
                          fieldName: 'نوع الطعام',
                        ),
                      ),
                    ),
                  SizedBox(height: AppConstants.paddingMD.h),
                  QuantityStepper(
                    label: 'الكمية (عدد الأشخاص)',
                    controller: _quantityController,
                    isRequired: true,
                    validator: positiveIntegerValidator(),
                  ),
                  SizedBox(height: AppConstants.paddingMD.h),
                  CustomTextField(
                    label: 'وصف إضافي (اختياري)',
                    hint: 'أي تفاصيل تساعد الجمعية، مثل طريقة التخزين',
                    controller: _descriptionController,
                    maxLines: 3,
                  ),
                  SizedBox(height: AppConstants.paddingXL.h),

                  _SectionHeader('حالة الطعام'),
                  _FoodStateSection(),
                  SizedBox(height: AppConstants.paddingXL.h),

                  _SectionHeader('صور الطعام (حتى 4 صور)'),
                  SizedBox(height: AppConstants.paddingMD.h),
                  _EditImagesPicker(
                    existingUrls: _existingImageUrls,
                    newImages: _newImages,
                    onAdd: _existingImageUrls.length + _newImages.length <
                            _maxImages
                        ? _pickImages
                        : null,
                    onRemoveExisting: _removeExistingImage,
                    onRemoveNew: _removeNewImage,
                  ),
                  SizedBox(height: AppConstants.paddingXL.h),

                  _SectionHeader('التوقيت'),
                  CustomTextField(
                    label: 'آخر وقت للاستلام',
                    hint: 'متى يجب أن تستلم الجمعية التبرع؟',
                    prefixIcon: Icons.schedule_rounded,
                    controller: _pickupUntilController,
                    readOnly: true,
                    isRequired: true,
                    onTap: () => _pickDateTime(isPickup: true),
                    validator: (_) => _pickupUntil == null
                        ? 'يرجى تحديد آخر وقت للاستلام'
                        : null,
                  ),
                  SizedBox(height: AppConstants.paddingMD.h),
                  CustomTextField(
                    label: 'صالح حتى',
                    hint: 'حتى متى يبقى الطعام صالحاً للاستهلاك؟',
                    prefixIcon: Icons.event_available_rounded,
                    controller: _validUntilController,
                    readOnly: true,
                    isRequired: true,
                    onTap: () => _pickDateTime(isPickup: false),
                    validator: (_) => _validUntil == null
                        ? 'يرجى تحديد وقت انتهاء الصلاحية'
                        : null,
                  ),
                  SizedBox(height: AppConstants.paddingXL.h),

                  _SectionHeader('الموقع'),
                  CustomTextField(
                    label: 'عنوان الاستلام',
                    hint: 'الحي، الشارع، أقرب معلم',
                    controller: _addressController,
                    maxLines: 2,
                    isRequired: true,
                    validator: requiredFieldValidator(
                      fieldName: 'عنوان الاستلام',
                    ),
                  ),
                  SizedBox(height: AppConstants.paddingMD.h),
                  CustomTextField(
                    label: 'ملاحظات الوصول (اختياري)',
                    hint: 'مثال: اتصل قبل الوصول بـ 15 دقيقة',
                    controller: _pickupNotesController,
                    maxLines: 2,
                  ),
                  SizedBox(height: AppConstants.paddingXL.h),

                  _SectionHeader('التواصل'),
                  CustomTextField(
                    label: 'رقم التواصل',
                    hint: 'رقم الهاتف الذي تتواصل معك الجمعية عبره',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    isRequired: true,
                    validator: phoneValidator,
                  ),
                  SizedBox(height: AppConstants.paddingXXL.h),

                  CustomButton(
                    label: 'حفظ التعديلات',
                    onPressed: _submit,
                    isLoading: state.status == BlocStatus.loading,
                  ),
                  SizedBox(height: AppConstants.paddingMD.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickDateTime({required bool isPickup}) async {
    final now = DateTime.now();
    final initial = isPickup ? _pickupUntil : _validUntil;
    final first = isPickup ? now : (_pickupUntil ?? now);
    final last = isPickup ? _validUntil : null;

    final date = await showDatePicker(
      context: context,
      initialDate: initial != null && initial.isAfter(first) ? initial : first,
      firstDate: first,
      lastDate: last ?? now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
    );
    if (time == null) return;

    final result = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (!result.isAfter(DateTime.now())) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن اختيار وقت في الماضي — اختر وقتاً قادماً'),
        ),
      );
      return;
    }

    setState(() {
      if (isPickup) {
        _pickupUntil = result;
        _pickupUntilController.text = DateFormatter.formatDateTime(result);
      } else {
        _validUntil = result;
        _validUntilController.text = DateFormatter.formatDateTime(result);
      }
    });
    _formKey.currentState?.validate();
  }
}

// ── Small shared pieces (kept local to the edit form) ─────────────────────────

/// Photo strip for the edit form: photos already stored on the server (network
/// images whose removal records their id) followed by newly picked files,
/// plus an add tile while under the cap. Mirrors the create form's picker.
class _EditImagesPicker extends StatelessWidget {
  final List<String> existingUrls;
  final List<File> newImages;
  final VoidCallback? onAdd;
  final ValueChanged<int> onRemoveExisting;
  final ValueChanged<int> onRemoveNew;

  const _EditImagesPicker({
    required this.existingUrls,
    required this.newImages,
    this.onAdd,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget removeBadge(VoidCallback onTap) => PositionedDirectional(
          end: 0,
          top: 0,
          child: Material(
            color: colorScheme.error,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(3.r),
                child: Icon(
                  Icons.close_rounded,
                  size: 14.r,
                  color: colorScheme.onError,
                ),
              ),
            ),
          ),
        );

    return SizedBox(
      height: 92.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          for (var i = 0; i < existingUrls.length; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(end: 8.w),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMD.r,
                    ),
                    child: Image.network(
                      existingUrls[i],
                      width: 92.r,
                      height: 92.r,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 92.r,
                        height: 92.r,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  removeBadge(() => onRemoveExisting(i)),
                ],
              ),
            ),
          for (var i = 0; i < newImages.length; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(end: 8.w),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMD.r,
                    ),
                    child: Image.file(
                      newImages[i],
                      width: 92.r,
                      height: 92.r,
                      fit: BoxFit.cover,
                    ),
                  ),
                  removeBadge(() => onRemoveNew(i)),
                ],
              ),
            ),
          if (onAdd != null)
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
              child: Container(
                width: 92.r,
                height: 92.r,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
                  border: Border.all(
                    color: colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_rounded,
                      size: 24.r,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'إضافة',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
              color: Theme.of(context).colorScheme.primary,
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

class _CategoryDropdown extends StatelessWidget {
  final CreateDonationState state;

  const _CategoryDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.categoriesStatus == BlocStatus.loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (state.categories.isEmpty) {
      return Text(
        'لا توجد أنواع طعام متاحة حالياً',
        style: AppTextStyles.bodySmall.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    // Keyed by the selection: DropdownButtonFormField asserts when its
    // initialValue changes between builds, so we recreate it instead.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: [
              const TextSpan(text: 'نوع الطعام'),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppConstants.paddingXS.h),
        DropdownButtonFormField<int>(
          key: ValueKey('category-${state.selectedCategoryId ?? 'none'}'),
          initialValue: state.selectedCategoryId,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.fastfood_outlined),
          ),
          items: state.categories.map((category) {
            return DropdownMenuItem(value: category.id, child: Text(category.nameAr));
          }).toList(),
          onChanged: (id) {
            final category = state.categories.firstWhere((c) => c.id == id);
            context.read<CreateDonationCubit>().selectCategory(category);
          },
          validator: (value) => value == null
              ? 'يرجى اختيار نوع الطعام'
              : null,
        ),
      ],
    );
  }
}


/// Cooking-state picker with the same rule as the create form: locked to the
/// category default, editable only when the category is "غير ذلك".
class _FoodStateSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<CreateDonationCubit, CreateDonationState>(
      buildWhen: (previous, current) =>
          previous.needsCooking != current.needsCooking ||
          previous.selectedCategoryId != current.selectedCategoryId,
      builder: (context, state) {
        final canEdit = state.selectedCategory?.requiresCustomName ?? false;

        Widget chip({
          required String label,
          required IconData icon,
          required bool selected,
          required VoidCallback? onTap,
        }) {
          final fg = selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;
          final locked = onTap == null;
          return Expanded(
            child: Opacity(
              opacity: locked && !selected ? 0.55 : 1.0,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: selected ? colorScheme.primary : colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
                    border: Border.all(
                      color: selected ? colorScheme.primary : colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (locked && selected) ...[
                        Icon(Icons.lock_rounded, size: 13.r, color: fg),
                        SizedBox(width: 5.w),
                      ],
                      Icon(icon, size: 20.r, color: fg),
                      SizedBox(width: 8.w),
                      Text(
                        label,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: fg,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            Row(
              children: [
                chip(
                  label: 'جاهز للأكل',
                  icon: Icons.restaurant_rounded,
                  selected: !state.needsCooking,
                  onTap: canEdit
                      ? () => context
                            .read<CreateDonationCubit>()
                            .setNeedsCooking(false)
                      : null,
                ),
                SizedBox(width: AppConstants.paddingMD.w),
                chip(
                  label: 'يحتاج طهي',
                  icon: Icons.local_fire_department_rounded,
                  selected: state.needsCooking,
                  onTap: canEdit
                      ? () => context
                            .read<CreateDonationCubit>()
                            .setNeedsCooking(true)
                      : null,
                ),
              ],
            ),
            SizedBox(height: AppConstants.paddingSM.h),
            Text(
              canEdit
                  ? 'الصنف "غير ذلك" — اختر الحالة المناسبة'
                  : 'تُحدد تلقائياً حسب نوع الطعام',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11.sp,
              ),
            ),
          ],
        );
      },
    );
  }
}
