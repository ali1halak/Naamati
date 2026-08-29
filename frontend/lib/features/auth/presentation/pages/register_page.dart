import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../bloc/register_cubit.dart';
import '../bloc/register_state.dart';

enum RegisterAccountType { donor, charity }

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key, this.initialType = RegisterAccountType.donor});

  final RegisterAccountType initialType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RegisterCubit>(),
      child: _RegisterPageView(initialType: initialType),
    );
  }
}

class _RegisterPageView extends StatefulWidget {
  const _RegisterPageView({required this.initialType});

  final RegisterAccountType initialType;

  @override
  State<_RegisterPageView> createState() => _RegisterPageViewState();
}

class _RegisterPageViewState extends State<_RegisterPageView> {
  late RegisterAccountType _accountType;
  final _formKey = GlobalKey<FormState>();

  final _donorNameController = TextEditingController();
  final _donorTypeController = TextEditingController(text: 'restaurant');
  final _donorEmailController = TextEditingController();
  final _donorPhoneController = TextEditingController();
  final _donorPasswordController = TextEditingController();
  final _donorConfirmPasswordController = TextEditingController();

  final _charityNameController = TextEditingController();
  final _charityEmailController = TextEditingController();
  final _charityPhoneController = TextEditingController();
  final _charityPasswordController = TextEditingController();
  final _charityConfirmPasswordController = TextEditingController();
  final _charityAddressController = TextEditingController();
  final _charityWorkStartController = TextEditingController();
  final _charityWorkEndController = TextEditingController();
  Uint8List? _charityLicenseDocumentBytes;
  String? _charityLicenseDocumentName;
  bool _hasKitchen = false;

  @override
  void initState() {
    super.initState();
    _accountType = widget.initialType;
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_accountType == RegisterAccountType.donor) {
      context.read<RegisterCubit>().registerDonor(
        name: _donorNameController.text.trim(),
        type: _donorTypeController.text.trim(),
        email: _donorEmailController.text.trim(),
        phone: _donorPhoneController.text.trim(),
        password: _donorPasswordController.text,
        passwordConfirmation: _donorConfirmPasswordController.text,
      );
      return;
    }

    context.read<RegisterCubit>().registerCharity(
      name: _charityNameController.text.trim(),
      email: _charityEmailController.text.trim(),
      phone: _charityPhoneController.text.trim(),
      password: _charityPasswordController.text,
      passwordConfirmation: _charityConfirmPasswordController.text,
      hasKitchen: _hasKitchen,
      address: _charityAddressController.text.trim(),
      workStart: _charityWorkStartController.text,
      workEnd: _charityWorkEndController.text,
      licenseDocumentBytes: _charityLicenseDocumentBytes,
      licenseDocumentName: _charityLicenseDocumentName,
    );
  }

  Future<void> _pickLicenseDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result == null) {
      return;
    }

    final file = result.files.single;
    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر قراءة ملف الترخيص المختار')),
      );
      return;
    }

    const maxLicenseBytes = 5 * 1024 * 1024;
    if (file.bytes!.lengthInBytes > maxLicenseBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ملف الترخيص يجب أن يكون 5MB أو أقل')),
      );
      return;
    }

    setState(() {
      _charityLicenseDocumentBytes = file.bytes;
      _charityLicenseDocumentName = file.name;
    });
  }

  void _revalidateConfirmPasswords() {
    if (_formKey.currentState == null) {
      return;
    }

    if (_donorConfirmPasswordController.text.isNotEmpty ||
        _charityConfirmPasswordController.text.isNotEmpty) {
      _formKey.currentState!.validate();
    }
  }

  String? _charityWorkEndValidator(String? value) {
    final baseError = requiredFieldValidator(fieldName: 'وقت انتهاء العمل')(
      value,
    );
    if (baseError != null) {
      return baseError;
    }

    final start = _charityWorkStartController.text.trim();
    final end = value?.trim() ?? '';
    if (start.isNotEmpty && end.isNotEmpty && end.compareTo(start) <= 0) {
      return 'وقت الانتهاء يجب أن يكون بعد وقت البدء.';
    }

    return null;
  }

  @override
  void dispose() {
    _donorNameController.dispose();
    _donorTypeController.dispose();
    _donorEmailController.dispose();
    _donorPhoneController.dispose();
    _donorPasswordController.dispose();
    _donorConfirmPasswordController.dispose();
    _charityNameController.dispose();
    _charityEmailController.dispose();
    _charityPhoneController.dispose();
    _charityPasswordController.dispose();
    _charityConfirmPasswordController.dispose();
    _charityAddressController.dispose();
    _charityWorkStartController.dispose();
    _charityWorkEndController.dispose();
    super.dispose();
  }

  Widget _buildSegmentSelector() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              title: 'متبرع',
              selected: _accountType == RegisterAccountType.donor,
              onTap: () =>
                  setState(() => _accountType = RegisterAccountType.donor),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _SegmentButton(
              title: 'جمعية خيرية',
              selected: _accountType == RegisterAccountType.charity,
              onTap: () =>
                  setState(() => _accountType = RegisterAccountType.charity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          label: 'الاسم الكامل',
          hint: 'أدخل اسمك الكامل',
          controller: _donorNameController,
          validator: requiredFieldValidator(fieldName: 'الاسم الكامل'),
          prefixIcon: Icons.person_outline,
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        DropdownButtonFormField<String>(
          initialValue: _donorTypeController.text,
          decoration: InputDecoration(
            labelText: 'نوع الحساب',
            prefixIcon: const Icon(Icons.category_outlined),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          items: const [
            DropdownMenuItem(value: 'individual', child: Text('فرد')),
            DropdownMenuItem(value: 'restaurant', child: Text('مطعم')),
            DropdownMenuItem(value: 'hotel', child: Text('فندق')),
            DropdownMenuItem(value: 'company', child: Text('شركة')),
          ],
          onChanged: (value) {
            if (value != null) {
              _donorTypeController.text = value;
            }
          },
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        CustomTextField(
          label: 'البريد الإلكتروني',
          hint: 'example@domain.com',
          controller: _donorEmailController,
          keyboardType: TextInputType.emailAddress,
          validator: emailValidator,
          prefixIcon: Icons.email_outlined,
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        CustomTextField(
          label: 'رقم الهاتف',
          hint: '966XXXXXXXXX',
          controller: _donorPhoneController,
          keyboardType: TextInputType.phone,
          validator: phoneValidator,
          prefixIcon: Icons.phone_outlined,
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        CustomTextField(
          label: 'كلمة المرور',
          controller: _donorPasswordController,
          obscureText: true,
          onChanged: (_) => _revalidateConfirmPasswords(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: passwordValidator,
          prefixIcon: Icons.lock_outline,
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        CustomTextField(
          label: 'تأكيد كلمة المرور',
          controller: _donorConfirmPasswordController,
          obscureText: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: confirmPasswordValidator(
            () => _donorPasswordController.text,
          ),
          prefixIcon: Icons.lock_reset_outlined,
        ),
      ],
    );
  }

  Widget _buildCharityForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          label: 'اسم الجمعية',
          hint: 'اسم الجمعية الخيرية',
          controller: _charityNameController,
          validator: requiredFieldValidator(fieldName: 'اسم الجمعية'),
          prefixIcon: Icons.business_outlined,
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        CustomTextField(
          label: 'البريد الإلكتروني',
          hint: 'charity@example.com',
          controller: _charityEmailController,
          keyboardType: TextInputType.emailAddress,
          validator: emailValidator,
          prefixIcon: Icons.email_outlined,
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        CustomTextField(
          label: 'رقم الهاتف',
          hint: '0911111111',
          controller: _charityPhoneController,
          keyboardType: TextInputType.phone,
          validator: phoneValidator,
          prefixIcon: Icons.phone_outlined,
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        CustomTextField(
          label: 'كلمة المرور',
          controller: _charityPasswordController,
          obscureText: true,
          onChanged: (_) => _revalidateConfirmPasswords(),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: passwordValidator,
          prefixIcon: Icons.lock_outline,
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        CustomTextField(
          label: 'تأكيد كلمة المرور',
          controller: _charityConfirmPasswordController,
          obscureText: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: confirmPasswordValidator(
            () => _charityPasswordController.text,
          ),
          prefixIcon: Icons.lock_reset_outlined,
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        Row(
          children: [
            Expanded(
              child: Text(
                'هل لديك مطبخ؟',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Switch(
              value: _hasKitchen,
              activeThumbColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) => setState(() => _hasKitchen = value),
            ),
          ],
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        CustomTextField(
          label: 'العنوان',
          hint: 'حلب - طريق النبك',
          controller: _charityAddressController,
          validator: requiredFieldValidator(fieldName: 'العنوان'),
          prefixIcon: Icons.location_on_outlined,
        ),
        SizedBox(height: AppConstants.paddingLG.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _charityWorkStartController,
                readOnly: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _charityWorkStartController.text =
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                    });
                    _formKey.currentState?.validate();
                  }
                },
                validator: requiredFieldValidator(fieldName: 'وقت بدء العمل'),
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
                controller: _charityWorkEndController,
                readOnly: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _charityWorkEndController.text =
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                    });
                    _formKey.currentState?.validate();
                  }
                },
                validator: _charityWorkEndValidator,
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
        OutlinedButton.icon(
          onPressed: _pickLicenseDocument,
          style: OutlinedButton.styleFrom(
            minimumSize: Size.fromHeight(AppConstants.buttonHeight.h),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
            ),
          ),
          icon: Icon(
            Icons.upload_file_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: Text(
            _charityLicenseDocumentName ?? 'إرفاق ملف الترخيص',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state.isSuccess) {
          final user = state.user;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
          );
          if (user?.accountType == 'charity') {
            if (user?.status == 'suspended') {
              context.go(RouteNames.charitySuspended);
            } else if (user?.status == 'pending') {
              context.go(RouteNames.charityPending);
            } else {
              context.go(RouteNames.home);
            }
          } else {
            context.go(RouteNames.home);
          }
        } else if (state.isFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'فشل إنشاء الحساب')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          title: Text(
            'نعمتي',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.all(AppConstants.paddingLG.w),
              child: Column(
                children: [
                  SizedBox(height: AppConstants.paddingSM.h),
                  _buildSegmentSelector(),
                  SizedBox(height: AppConstants.paddingXL.h),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusLG.r,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.paddingLG.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _accountType == RegisterAccountType.donor
                                  ? 'إنشاء حساب متبرع'
                                  : 'إنشاء حساب جمعية خيرية',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(color: colorScheme.primary),
                            ),
                            SizedBox(height: AppConstants.paddingXL.h),
                            if (_accountType == RegisterAccountType.donor)
                              _buildDonorForm()
                            else
                              _buildCharityForm(),
                            SizedBox(height: AppConstants.paddingXL.h),
                            BlocBuilder<RegisterCubit, RegisterState>(
                              builder: (context, state) {
                                return CustomButton(
                                  label: 'إنشاء الحساب',
                                  onPressed: _submit,
                                  isLoading: state.isLoading,
                                  leadingIcon: Icon(
                                    Icons.person_add_alt_1_rounded,
                                    size: AppConstants.iconSizeSM.r,
                                    color: colorScheme.onPrimary,
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: AppConstants.paddingMD.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'هل لديك حساب بالفعل؟ ',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () => context.go(RouteNames.login),
                                  child: Text(
                                    'تسجيل الدخول',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(color: colorScheme.primary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
