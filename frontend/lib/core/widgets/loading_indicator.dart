import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// A centered loading indicator.
///
/// Use [LoadingIndicator.fullScreen] for overlay-style full-page loading,
/// or [LoadingIndicator.inline] for embedding inside a list/card.
class LoadingIndicator extends StatelessWidget {
  /// Color of the spinner (defaults to [AppColors.primary]).
  final Color? color;

  /// Size of the spinner container.
  final double size;

  /// If `true`, wraps the indicator in an [Expanded] + [Center] suitable for
  /// use directly inside a [Column] or [ListView].
  final bool expandToFill;

  const LoadingIndicator({super.key, this.color, this.size = 40.0, this.expandToFill = false});

  /// Full-screen centered loading widget (e.g. initial page load).
  const LoadingIndicator.fullScreen({super.key}) : color = null, size = 48.0, expandToFill = true;

  /// Compact inline loading widget (e.g. inside a card or list item).
  const LoadingIndicator.inline({super.key, this.color}) : size = 24.0, expandToFill = false;

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size.w,
      height: size.w,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
      ),
    );

    if (expandToFill) {
      return Center(child: indicator);
    }
    return indicator;
  }
}
