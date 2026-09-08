import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/location/open_in_maps_button.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';

/// Bottom sheet asking the charity for its expected arrival time before it
/// claims a request — the backend requires `eta_minutes` (5–480) so the donor
/// knows when to expect pickup. Also offers "التحديد على الخريطة" so the
/// charity can check the route before committing to an ETA.
class AcceptRequestSheet extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const AcceptRequestSheet({super.key, this.latitude, this.longitude});

  /// Shows the sheet and returns the chosen ETA in minutes, or null if the
  /// user dismissed it.
  static Future<int?> show(
    BuildContext context, {
    double? latitude,
    double? longitude,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AcceptRequestSheet(latitude: latitude, longitude: longitude),
    );
  }

  @override
  State<AcceptRequestSheet> createState() => _AcceptRequestSheetState();
}

class _AcceptRequestSheetState extends State<AcceptRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _etaController = TextEditingController(text: '30');

  @override
  void dispose() {
    _etaController.dispose();
    super.dispose();
  }

  String? _validateEta(String? value) {
    final minutes = int.tryParse(value?.trim() ?? '');
    if (minutes == null) return 'يرجى إدخال رقم صحيح.';
    if (minutes < 5 || minutes > 480) {
      return 'يجب أن تكون المدة بين 5 و 480 دقيقة.';
    }
    return null;
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(int.parse(_etaController.text.trim()));
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
          child: Form(
            key: _formKey,
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
                  'قبول الطلب',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18.sp,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'خلال كم دقيقة تتوقع الوصول لاستلام الطلب؟',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13.sp,
                  ),
                ),
                if (widget.latitude != null && widget.longitude != null) ...[
                  SizedBox(height: 10.h),
                  Center(
                    child: OpenInMapsButton(
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                    ),
                  ),
                ],
                SizedBox(height: AppConstants.paddingLG.h),
                CustomTextField(
                  label: 'الوقت المتوقع للوصول (بالدقائق)',
                  hint: 'مثال: 30',
                  controller: _etaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validateEta,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                SizedBox(height: AppConstants.paddingLG.h),
                CustomButton(label: 'تأكيد القبول', onPressed: _confirm),
                SizedBox(height: AppConstants.paddingSM.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
