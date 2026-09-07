import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';

/// Shown while a charity account is `pending` or `suspended`.
///
/// The admin can approve/reinstate the account at any moment from the panel,
/// so this screen polls `/me` every 15s (the same interval the donation
/// tracking screen already auto-refreshes at) and also offers a manual
/// "تحديث الحالة" button — the account switches to the real charity home the
/// moment its status turns `active`, without the user having to log out and
/// back in.
class CharityAccountStatusPage extends StatefulWidget {
  const CharityAccountStatusPage({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  State<CharityAccountStatusPage> createState() =>
      _CharityAccountStatusPageState();
}

class _CharityAccountStatusPageState extends State<CharityAccountStatusPage> {
  static const _pollInterval = Duration(seconds: 15);

  Timer? _pollTimer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkStatus());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus({bool manual = false}) async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    final result = await sl<GetCurrentUserUseCase>()(const NoParams());
    if (!mounted) return;
    setState(() => _isChecking = false);

    result.fold(
      (_) {}, // Transient network hiccup — the next poll will retry.
      (user) {
        if (user.accountType != 'charity') return;
        final route = _routeFor(user.status);
        if (route != null &&
            route != GoRouterState.of(context).matchedLocation) {
          _pollTimer?.cancel();
          context.go(route);
          return;
        }
        if (manual && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا يوجد تغيير على حالة الحساب بعد.')),
          );
        }
      },
    );
  }

  String? _routeFor(String? status) => switch (status) {
    'active' => RouteNames.charityHome,
    'suspended' => RouteNames.charitySuspended,
    'pending' => RouteNames.charityPending,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('نعمتي'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppConstants.paddingLG.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 72.r, color: colorScheme.primary),
                SizedBox(height: AppConstants.paddingLG.h),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: AppConstants.paddingMD.h),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: AppConstants.paddingXL.h),
                OutlinedButton.icon(
                  onPressed: _isChecking
                      ? null
                      : () => _checkStatus(manual: true),
                  icon: _isChecking
                      ? SizedBox(
                          width: 16.r,
                          height: 16.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: const Text('تحديث الحالة'),
                ),
                SizedBox(height: AppConstants.paddingMD.h),
                FilledButton(
                  onPressed: () => context.go(RouteNames.login),
                  child: const Text('العودة لتسجيل الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
