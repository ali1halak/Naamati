import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../domain/usecases/get_notifications_usecase.dart';

/// Bell icon with a red unread-count badge, used in both home app bars.
///
/// Self-contained: fetches its own unread count on mount and again whenever
/// the user returns from the notifications page (where opening it marks rows
/// as read), so the badge never needs a parent to manage its state.
class NotificationBellIcon extends StatefulWidget {
  const NotificationBellIcon({super.key});

  @override
  State<NotificationBellIcon> createState() => _NotificationBellIconState();
}

class _NotificationBellIconState extends State<NotificationBellIcon> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final result = await sl<GetNotificationsUseCase>()(
      const GetNotificationsParams(isRead: false),
    );
    if (!mounted) return;
    result.fold((_) {}, (page) => setState(() => _unreadCount = page.total));
  }

  Future<void> _openNotifications() async {
    await context.push(RouteNames.notifications);
    if (mounted) _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: _openNotifications,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 24.r,
            color: colorScheme.onSurface,
          ),
          if (_unreadCount > 0)
            Positioned(
              right: -4.w,
              top: -3.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.r),
                constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 1.5.w),
                ),
                child: Center(
                  child: Text(
                    _unreadCount > 99 ? '99+' : '$_unreadCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onError,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
