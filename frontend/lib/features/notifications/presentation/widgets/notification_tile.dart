import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/app_notification.dart';

/// One row in the notifications feed — icon, title/body built from
/// [AppNotification.kind] + payload, relative time, and an unread dot.
///
/// Text mirrors the Arabic wording `NotificationService` sends as the FCM
/// push for the same event, so the in-app feed and the push banner read the
/// same way.
class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData get _icon => switch (notification.kind) {
    NotificationKind.requestAccepted => Icons.check_circle_outline_rounded,
    NotificationKind.handoverConfirmed => Icons.inventory_2_outlined,
    NotificationKind.requestCancelled => Icons.cancel_outlined,
    NotificationKind.unknown => Icons.notifications_outlined,
  };

  ({String title, String body}) get _content {
    final payload = notification.payload;
    switch (notification.kind) {
      case NotificationKind.requestAccepted:
        final charityName = payload['charity_name'] as String?;
        return (
          title: 'تم قبول طلبك',
          body: charityName != null
              ? 'قبلت جمعية $charityName طلب التبرع الخاص بك.'
              : 'قبلت إحدى الجمعيات طلب التبرع الخاص بك.',
        );
      case NotificationKind.handoverConfirmed:
        final donorName = payload['donor_name'] as String?;
        return (
          title: 'تم تأكيد الاستلام',
          body: donorName != null
              ? 'تم تأكيد استلام التبرع من $donorName.'
              : 'تم تأكيد استلام التبرع.',
        );
      case NotificationKind.requestCancelled:
        if (payload['cancelled_by'] == 'admin') {
          return (
            title: 'تم إلغاء طلبك',
            body: 'قامت الإدارة بإلغاء طلب التبرع الخاص بك.',
          );
        }
        final donorName = payload['donor_name'] as String?;
        return (
          title: 'تم إلغاء الطلب',
          body: donorName != null
              ? 'ألغى $donorName طلب التبرع الذي قبلته.'
              : 'ألغى المتبرع طلب التبرع الذي قبلته.',
        );
      case NotificationKind.unknown:
        return (title: 'إشعار', body: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = _content;
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isUnread
            ? colorScheme.primaryContainer.withValues(alpha: 0.25)
            : Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMD.w,
          vertical: AppConstants.paddingMD.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 22.r, color: colorScheme.primary),
            ),
            SizedBox(width: AppConstants.paddingMD.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    content.body,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    DateFormatter.formatRelative(notification.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Padding(
                padding: EdgeInsets.only(top: 4.h, right: 4.w),
                child: Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
