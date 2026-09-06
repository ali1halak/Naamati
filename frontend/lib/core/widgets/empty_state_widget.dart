import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_text_styles.dart';
import '../constants/app_constants.dart';

/// A reusable empty-state placeholder widget.
///
/// Displays an [icon], a [title], an optional [subtitle], and an optional
/// [action] button — covering the most common empty-state patterns.
class EmptyStateWidget extends StatelessWidget {
  /// Large icon displayed at the top.
  final IconData icon;

  /// Primary message (e.g. "No results found").
  final String title;

  /// Secondary explanatory text (optional).
  final String? subtitle;

  /// Optional call-to-action button.
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Scrollable + minimum-height pattern: vertically centered when the
    // viewport is tall, scrolls instead of overflowing when it is short
    // (e.g. a tab whose header eats most of the height).
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.all(AppConstants.paddingXL.r),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88.r,
                  height: 88.r,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 44.r, color: colorScheme.primary),
                ),
                SizedBox(height: AppConstants.paddingLG.h),
                Text(
                  title,
                  style: AppTextStyles.titleMedium,
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppConstants.paddingSM.h),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (action != null) ...[
                  SizedBox(height: AppConstants.paddingXL.h),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
