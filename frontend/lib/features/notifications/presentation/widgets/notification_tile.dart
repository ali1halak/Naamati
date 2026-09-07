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
    NotificationKind.newRequestAvailable => Icons.campaign_outlined,
    NotificationKind.awaitingOtherConfirmation => Icons.hourglass_top_rounded,
    NotificationKind.distributionCompleted => Icons.volunteer_activism_outlined,
    NotificationKind.requestExpired => Icons.timer_off_outlined,
    NotificationKind.requestNoShow => Icons.person_off_outlined,
    NotificationKind.newRating => Icons.star_outline_rounded,
    NotificationKind.charityApproved => Icons.verified_outlined,
    NotificationKind.charitySuspended => Icons.block_outlined,
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
      case NotificationKind.newRequestAvailable:
        final categoryName = payload['category_name'] as String?;
        return (
          title: 'طلب تبرع جديد متاح',
          body: categoryName != null
              ? 'تم نشر طلب تبرع جديد ($categoryName) قد يهمّك.'
              : 'تم نشر طلب تبرع جديد قد يهمّك.',
        );
      case NotificationKind.awaitingOtherConfirmation:
        final confirmedByDonor = payload['confirmed_by'] == 'donor';
        return (
          title: 'بانتظار تأكيدك',
          body: confirmedByDonor
              ? 'أكّد المتبرع تسليم الطعام — أكّد استلامك من جهتك لإتمام العملية.'
              : 'أكّدت الجمعية استلام الطعام — أكّد تسليمك من جهتك لإتمام العملية.',
        );
      case NotificationKind.distributionCompleted:
        final charityName = payload['charity_name'] as String?;
        return (
          title: 'تم توزيع تبرعك',
          body: charityName != null
              ? 'وزّعت جمعية $charityName تبرعك بنجاح. جزاك الله خيراً.'
              : 'تم توزيع تبرعك بنجاح. جزاك الله خيراً.',
        );
      case NotificationKind.requestExpired:
        return (
          title: 'انتهت صلاحية طلبك',
          body: 'انتهت صلاحية الطعام في طلبك دون أن تقبله أي جمعية.',
        );
      case NotificationKind.requestNoShow:
        final charityName = payload['charity_name'] as String?;
        return (
          title: 'لم تحضر الجمعية',
          body: charityName != null
              ? 'لم تحضر جمعية $charityName لاستلام طلبك في الموعد المحدد.'
              : 'لم تحضر الجمعية المقبولة لاستلام طلبك في الموعد المحدد.',
        );
      case NotificationKind.newRating:
        final stars = payload['stars'];
        return (
          title: 'تقييم جديد',
          body: stars != null
              ? 'قيّمك أحد المتبرعين بـ $stars من 5 نجوم.'
              : 'حصلت على تقييم جديد.',
        );
      case NotificationKind.charityApproved:
        return (
          title: 'تم تفعيل حسابك',
          body:
              'تم اعتماد حساب جمعيتكم — يمكنكم الآن تصفح طلبات التبرع وقبولها.',
        );
      case NotificationKind.charitySuspended:
        return (
          title: 'تم إيقاف حسابك',
          body:
              'تم إيقاف حساب جمعيتكم من قبل الإدارة. للاستفسار يرجى التواصل معنا.',
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
