import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/custom_button.dart';

/// Landing / welcome screen shown before [LoginPage].
///
/// Dark-green hero with rounded bottom, logo, title and subtitle on top;
/// beige action area with two register CTAs and a login link at the bottom.
/// All colors are read from the active [ColorScheme] so the screen adapts to
/// light/dark themes.
///
/// Route: [RouteNames.welcome] (`/welcome`), set as [AppRouter.initialLocation].
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ── Green hero ───────────────────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32.r),
                    bottomRight: Radius.circular(32.r),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 84.r,
                        height: 84.r,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.volunteer_activism_rounded,
                          size: 42.r,
                          color: colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'نعمتي',
                        style: textTheme.headlineLarge?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 28.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: Text(
                          'نحول فائض الطعام إلى نعمة تصل\nمستحقيها',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary.withValues(
                              alpha: 0.85,
                            ),
                            height: 1.6,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Action area ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.paddingLG.w,
                AppConstants.paddingXL.h,
                AppConstants.paddingLG.w,
                AppConstants.paddingLG.h +
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomButton(
                    label: 'إنشاء حساب',
                    onPressed: () => context.push(RouteNames.register),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'لديك حساب بالفعل؟ ',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(RouteNames.login),
                        child: Text(
                          'تسجيل الدخول',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
