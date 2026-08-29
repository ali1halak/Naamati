import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_constants.dart';

/// A reusable [TextFormField] wrapper with consistent Naamati styling.
///
/// Supports labels, hints, validators, obscure text, leading/trailing icons,
/// and keyboard type customisation — all without importing theme data.
class CustomTextField extends StatefulWidget {
  /// Input label displayed above the field.
  final String? label;

  /// Placeholder text shown inside the field.
  final String? hint;

  /// Optional validator function ([TextFormField.validator]-compatible).
  final String? Function(String?)? validator;

  /// Pre-fill the field with this controller.
  final TextEditingController? controller;

  /// Whether to obscure text (passwords).
  final bool obscureText;

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits.
  final ValueChanged<String>? onFieldSubmitted;

  /// Optional prefix icon.
  final IconData? prefixIcon;

  /// Optional suffix icon (overrides the obscure-text toggle if [obscureText] is true).
  final Widget? suffixIcon;

  /// Keyboard type (defaults to [TextInputType.text]).
  final TextInputType keyboardType;

  /// Text input action (defaults to [TextInputAction.next]).
  final TextInputAction textInputAction;

  /// Maximum number of lines (defaults to 1).
  final int maxLines;

  /// Whether the field is enabled.
  final bool enabled;

  /// When to run validation automatically.
  final AutovalidateMode? autovalidateMode;

  /// Focus node for programmatic focus control.
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.validator,
    this.controller,
    this.obscureText = false,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.enabled = true,
    this.autovalidateMode,
    this.focusNode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppConstants.paddingXS.h),
        ],
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _obscureText,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          enabled: widget.enabled,
          autovalidateMode: widget.autovalidateMode,
          focusNode: widget.focusNode,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: AppConstants.iconSizeMD.h)
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: AppConstants.iconSizeMD.h,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}
