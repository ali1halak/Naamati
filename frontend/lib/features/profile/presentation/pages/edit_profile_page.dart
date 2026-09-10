import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/location/pickup_location.dart';
import '../../../../core/location/pickup_location_field.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../domain/entities/my_profile.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_avatar.dart';

/// "تعديل الملف الشخصي" — receives the already-loaded [MyProfile] via
/// GoRouter `extra` (same convention as `EditDonationPage`) so it doesn't
/// need to re-fetch before rendering the form.
class EditProfilePage extends StatelessWidget {
  final MyProfile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>(),
      child: _EditProfileView(initialProfile: profile),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  final MyProfile initialProfile;

  const _EditProfileView({required this.initialProfile});

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  // Donor-only.
  late String _donorType;

  // Charity-only.
  PickupLocation? _selectedLocation;
  late final TextEditingController _workStartController;
  late final TextEditingController _workEndController;
  late bool _hasKitchen;

  MyProfile get _profile => widget.initialProfile;

  @override
  void initState() {
    super.initState();
    final donor = _profile.donor;
    final charity = _profile.charity;

    _nameController = TextEditingController(text: _profile.name);
    _phoneController = TextEditingController(
      text: donor?.phone ?? charity?.phone ?? '',
    );
    _donorType = donor?.type ?? 'individual';
    if (charity?.latitude != null && charity?.longitude != null) {
      _selectedLocation = PickupLocation(
        latitude: charity!.latitude!,
        longitude: charity.longitude!,
        address: charity.address,
      );
    }
    _workStartController = TextEditingController(
      text: charity?.workStart ?? '',
    );
    _workEndController = TextEditingController(text: charity?.workEnd ?? '');
    _hasKitchen = charity?.hasKitchen ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _workStartController.dispose();
    _workEndController.dispose();
    super.dispose();
  }

  String? _requiredTimeValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'مطلوب.';
    return null;
  }

  String? _workEndValidator(String? value) {
    final required = _requiredTimeValidator(value);
    if (required != null) return required;
    if (_workStartController.text.isNotEmpty &&
        value == _workStartController.text) {
      return 'يجب أن تكون نهاية الدوام بعد بدايتها.';
    }
    return null;
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;
    setState(() {
      controller.text =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    });
    _formKey.currentState?.validate();
  }

  bool _isPickingPhoto = false;

  Future<void> _pickPhoto() async {
    // The plugin throws `already_active` if a second pick starts before the
    // first one's picker UI has returned — a fast double-tap is enough to
    // trigger it, since [ProfileCubit]'s own loading state only flips after
    // pickImage() already resolved.
    if (_isPickingPhoto) return;
    _isPickingPhoto = true;
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null || !mounted) return;
      await context.read<ProfileCubit>().updatePhoto(File(picked.path));
    } on PlatformException {
      // Another pick is already in flight — ignore, it will complete on its own.
    } finally {
      _isPickingPhoto = false;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final isDonor = _profile.isDonor;
    if (!isDonor && _selectedLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى تحديد عنوان الجمعية')));
      return;
    }

    final ok = await context.read<ProfileCubit>().updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      type: isDonor ? _donorType : null,
      address: isDonor ? null : _selectedLocation!.address,
      latitude: isDonor ? null : _selectedLocation!.latitude,
      longitude: isDonor ? null : _selectedLocation!.longitude,
      workStart: isDonor ? null : _workStartController.text.trim(),
      workEnd: isDonor ? null : _workEndController.text.trim(),
      hasKitchen: isDonor ? null : _hasKitchen,
    );

    if (!mounted) return;
    if (ok) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDonor = _profile.isDonor;

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
            'تعديل الملف الشخصي',
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state.actionErrorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionErrorMessage!)),
              );
              context.read<ProfileCubit>().clearActionError();
            }
          },
          builder: (context, state) {
            final avatarUrl = state.profile?.avatarUrl ?? _profile.avatarUrl;
            final isUpdatingPhoto =
                state.actionInProgress == ProfileAction.updatePhoto;
            final isSaving =
                state.actionInProgress == ProfileAction.updateFields;

            return Form(
              key: _formKey,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.all(AppConstants.paddingLG.w),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: isUpdatingPhoto ? null : _pickPhoto,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ProfileAvatar(
                            imageUrl: avatarUrl,
                            name: _profile.name,
                            radius: 44,
                            showEditBadge: !isUpdatingPhoto,
                          ),
                          if (isUpdatingPhoto)
                            SizedBox(
                              width: 88.r,
                              height: 88.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppConstants.paddingXL.h),
                  CustomTextField(
                    label: 'الاسم',
                    controller: _nameController,
                    isRequired: true,
                    validator: requiredFieldValidator(fieldName: 'الاسم'),
                    prefixIcon: Icons.person_outline,
                  ),
                  SizedBox(height: AppConstants.paddingLG.h),
                  CustomTextField(
                    label: 'رقم الهاتف',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    isRequired: true,
                    validator: phoneValidator,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  SizedBox(height: AppConstants.paddingLG.h),
                  if (isDonor) ...[
                    Text('نوع الحساب', style: AppTextStyles.bodyMedium),
                    SizedBox(height: AppConstants.paddingXS.h),
                    DropdownButtonFormField<String>(
                      initialValue: _donorType,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'individual',
                          child: Text('فرد'),
                        ),
                        DropdownMenuItem(
                          value: 'restaurant',
                          child: Text('مطعم'),
                        ),
                        DropdownMenuItem(value: 'hotel', child: Text('فندق')),
                        DropdownMenuItem(value: 'company', child: Text('شركة')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _donorType = value);
                      },
                    ),
                  ] else ...[
                    PickupLocationField(
                      location: _selectedLocation,
                      onChanged: (location) =>
                          setState(() => _selectedLocation = location),
                      placeholderText: 'لم يتم تحديد عنوان الجمعية بعد',
                    ),
                    SizedBox(height: AppConstants.paddingLG.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _workStartController,
                            readOnly: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onTap: () => _pickTime(_workStartController),
                            validator: _requiredTimeValidator,
                            decoration: const InputDecoration(
                              labelText: 'بداية العمل',
                              prefixIcon: Icon(Icons.access_time_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: AppConstants.paddingMD.w),
                        Expanded(
                          child: TextFormField(
                            controller: _workEndController,
                            readOnly: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onTap: () => _pickTime(_workEndController),
                            validator: _workEndValidator,
                            decoration: const InputDecoration(
                              labelText: 'نهاية العمل',
                              prefixIcon: Icon(Icons.access_time_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppConstants.paddingLG.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'هل لديكم مطبخ؟',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                        Switch(
                          value: _hasKitchen,
                          activeThumbColor: colorScheme.primary,
                          onChanged: (value) =>
                              setState(() => _hasKitchen = value),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: AppConstants.paddingXL.h),
                  CustomButton(
                    label: 'حفظ التغييرات',
                    onPressed: _save,
                    isLoading: isSaving,
                  ),
                  SizedBox(height: AppConstants.paddingLG.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
