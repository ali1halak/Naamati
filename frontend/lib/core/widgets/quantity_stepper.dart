import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_constants.dart';
import '../theme/app_text_styles.dart';

/// A quantity field flanked by round −/+ stepper buttons.
///
/// Typing stays possible (digits only, validated by [validator]); the buttons
/// increment/decrement by [step], clamped to [min]/[max]. In the RTL layout
/// the − button sits on the right, the + on the left.
class QuantityStepper extends StatelessWidget {
  final TextEditingController controller;

  /// Label rendered above the field, same style as [CustomTextField].
  final String? label;

  /// Validator for the inner field (run on submit as usual).
  final String? Function(String?)? validator;

  final int min;
  final int max;
  final int step;

  /// When `true`, a red asterisk (*) is appended after the label to indicate
  /// the field is required.
  final bool isRequired;

  const QuantityStepper({
    super.key,
    required this.controller,
    this.label,
    this.validator,
    this.min = 1,
    this.max = 99999,
    this.step = 1,
    this.isRequired = false,
  });

  int get _current => int.tryParse(controller.text.trim()) ?? min - 1;

  void _bump(int delta) {
    final base = _current < min ? min - step : _current;
    final next = (base + delta).clamp(min, max);
    controller.text = '$next';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
              children: [
                TextSpan(text: label!),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppConstants.paddingXS.h),
        ],
        Row(
          children: [
            _StepButton(
              icon: Icons.remove_rounded,
              semanticLabel: 'إنقاص الكمية',
              onTap: () => _bump(-step),
              colorScheme: colorScheme,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextFormField(
                controller: controller,
                validator: validator,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'مثال: 20',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 14.h,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            _StepButton(
              icon: Icons.add_rounded,
              semanticLabel: 'زيادة الكمية',
              onTap: () => _bump(step),
              colorScheme: colorScheme,
            ),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _StepButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.primaryContainer,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Icon(icon, size: 20.r, color: colorScheme.onPrimaryContainer),
        ),
      ),
    );
  }
}
