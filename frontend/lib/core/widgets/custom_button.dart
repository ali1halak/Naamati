import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

/// A reusable button widget that shows a loading indicator when [isLoading]
/// is `true` and disables interaction until the operation completes.
///
/// Drop-in replacement for [ElevatedButton] in all feature UIs.
class CustomButton extends StatelessWidget {
  /// Button label.
  final String label;

  /// Called when the button is tapped (ignored while [isLoading]).
  final VoidCallback? onPressed;

  /// Shows a [CircularProgressIndicator] and disables tap when `true`.
  final bool isLoading;

  /// Override the default background color.
  final Color? backgroundColor;

  /// Override the default text/icon color.
  final Color? foregroundColor;

  /// Override the default text style.
  final TextStyle? textStyle;

  /// An optional icon placed before the label.
  final Widget? leadingIcon;

  /// Override default button width (defaults to [double.infinity]).
  final double? width;

  /// Override default button height (defaults to [AppConstants.buttonHeight]).
  final double? height;

  /// Override default border radius.
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.leadingIcon,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBg = backgroundColor ?? colorScheme.primary;
    final effectiveFg = foregroundColor ?? colorScheme.onPrimary;
    final effectiveRadius = borderRadius ?? AppConstants.radiusMD;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? AppConstants.buttonHeight.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBg,
          foregroundColor: effectiveFg,
          disabledBackgroundColor: effectiveBg.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveRadius.r)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 22.h,
                width: 22.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 8)],
                  Text(
                    label,
                    style: (textStyle ?? AppTextStyles.labelLarge).copyWith(color: effectiveFg),
                  ),
                ],
              ),
      ),
    );
  }
}
