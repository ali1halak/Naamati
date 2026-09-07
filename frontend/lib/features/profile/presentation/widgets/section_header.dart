import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Small uppercase-ish label above a group of [ProfileMenuTile]s, e.g.
/// "الحساب" / "التفضيلات".
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingXS.w,
        AppConstants.paddingMD.h,
        AppConstants.paddingXS.w,
        AppConstants.paddingSM.h,
      ),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}
