import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../bloc/distribution_form_cubit.dart';
import '../bloc/distribution_form_state.dart';

/// "بيانات التوزيع" — the charity may file how many people the food reached
/// right away, or skip and do it later (`POST /charity/requests/{id}/impact`).
class DistributionDataPage extends StatelessWidget {
  final int orderId;

  const DistributionDataPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DistributionFormCubit>(),
      child: _DistributionDataView(orderId: orderId),
    );
  }
}

class _DistributionDataView extends StatefulWidget {
  final int orderId;

  const _DistributionDataView({required this.orderId});

  @override
  State<_DistributionDataView> createState() => _DistributionDataViewState();
}

class _DistributionDataViewState extends State<_DistributionDataView> {
  final _formKey = GlobalKey<FormState>();
  final _familiesController = TextEditingController();
  final _individualsController = TextEditingController();
  final _areaController = TextEditingController();

  @override
  void dispose() {
    _familiesController.dispose();
    _individualsController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  // Leaves the whole accept → track → distribute flow behind, back at the
  // charity home rather than popping one screen at a time.
  void _goHome() => context.go(RouteNames.charityHome);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await context.read<DistributionFormCubit>().submit(
      orderId: widget.orderId,
      familiesCount: int.parse(_familiesController.text.trim()),
      individualsCount: int.parse(_individualsController.text.trim()),
      area: _areaController.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ بيانات التوزيع')));
      _goHome();
    }
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
          automaticallyImplyLeading: false,
          title: Text(
            'بيانات التوزيع',
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18.sp,
            ),
          ),
        ),
        body: BlocConsumer<DistributionFormCubit, DistributionFormState>(
          listener: (context, state) {
            if (state.isFailure && state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
          builder: (context, state) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.all(AppConstants.paddingLG.w),
              children: [
                SizedBox(height: AppConstants.paddingSM.h),
                Text(
                  'يمكنك تعبئة هذه البيانات فوراً أو لاحقاً',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppConstants.paddingXL.h),
                Container(
                  padding: EdgeInsets.all(AppConstants.paddingLG.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusLG.r,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.05),
                        blurRadius: 12.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          label: 'عدد العائلات المستفيدة',
                          hint: 'مثال: 50',
                          controller: _familiesController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          isRequired: true,
                          validator: positiveIntegerValidator(
                            fieldName: 'عدد العائلات',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          prefixIcon: Icons.groups_rounded,
                        ),
                        SizedBox(height: AppConstants.paddingMD.h),
                        CustomTextField(
                          label: 'عدد الأفراد المستفيدين',
                          hint: 'مثال: 250',
                          controller: _individualsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          isRequired: true,
                          validator: positiveIntegerValidator(
                            fieldName: 'عدد الأفراد',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          prefixIcon: Icons.person_rounded,
                        ),
                        SizedBox(height: AppConstants.paddingMD.h),
                        CustomTextField(
                          label: 'منطقة التوزيع',
                          hint: 'أدخل اسم المنطقة',
                          controller: _areaController,
                          isRequired: true,
                          validator: requiredFieldValidator(
                            fieldName: 'منطقة التوزيع',
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          prefixIcon: Icons.location_on_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppConstants.paddingXL.h),
                CustomButton(
                  label: 'حفظ البيانات',
                  onPressed: _submit,
                  isLoading: state.isSubmitting,
                ),
                SizedBox(height: AppConstants.paddingSM.h),
                CustomButton(
                  label: 'تعبئة لاحقاً',
                  onPressed: state.isSubmitting ? null : _goHome,
                  backgroundColor: Colors.transparent,
                  foregroundColor: colorScheme.primary,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
