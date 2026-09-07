import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';

/// Circular avatar with a network image, falling back to the name's
/// initials on a tinted background when there is no photo (or it fails to
/// load) — mirrors the initials logic already used for charity cards.
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;

  /// Small camera badge in the bottom-end corner — shown on the edit screen
  /// to signal the avatar is tappable.
  final bool showEditBadge;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 40,
    this.showEditBadge = false,
  });

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '؟';
    if (parts.length == 1) return parts.first.characters.first;
    return '${parts.first.characters.first}${parts.last.characters.first}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius.r,
          backgroundColor: colorScheme.primary,
          foregroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          onForegroundImageError: imageUrl != null ? (_, _) {} : null,
          child: Text(
            _initials,
            style: AppTextStyles.headlineSmall.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
              fontSize: (radius * 0.5).sp,
            ),
          ),
        ),
        if (showEditBadge)
          Positioned(
            bottom: -2.h,
            right: -2.w,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2.w),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 14.r,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
      ],
    );
  }
}
