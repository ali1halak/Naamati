import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../../features/profile/domain/usecases/update_fcm_token_usecase.dart';
import '../routes/app_router.dart';
import '../routes/route_names.dart';

/// Shown for every push while the app is foregrounded. Background/terminated
/// pushes instead use the channel/icon declared in AndroidManifest.xml.
const _channel = AndroidNotificationChannel(
  'naamati_default_channel',
  'إشعارات نعمتي',
  description: 'تحديثات حالة طلبات التبرع',
  importance: Importance.high,
);

/// FCM invokes this in a background isolate for a push that arrives while
/// the app is backgrounded/terminated — it must stay top-level and
/// re-initialise Firebase itself, since it doesn't share the main isolate's
/// state. No work is needed here: the system tray already shows the
/// notification from the payload using the manifest's default channel/icon;
/// tapping it is handled by [PushNotificationService]'s
/// onMessageOpenedApp/getInitialMessage handlers instead.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Owns every push-notification side effect: requesting permission,
/// registering/refreshing this device's FCM token with the backend, showing
/// a real banner while the app is open, and deep-linking to the relevant
/// donation/order on tap — whether the tap happened from the foreground
/// banner, the system tray, or a cold start from a terminated notification.
@lazySingleton
class PushNotificationService {
  final UpdateFcmTokenUseCase _updateFcmTokenUseCase;
  final FlutterLocalNotificationsPlugin _localNotifications;

  PushNotificationService(
    this._updateFcmTokenUseCase,
    this._localNotifications,
  );

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance.requestPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) {
          _navigateFromData(Map<String, dynamic>.from(jsonDecode(payload)));
        }
      },
    );

    await registerCurrentToken();
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (_) => registerCurrentToken(),
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _navigateFromData(message.data),
    );

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _navigateFromData(initialMessage.data);
    }
  }

  /// Best-effort: called at startup and on every token refresh, and again
  /// right after a successful login/registration (the earlier attempts
  /// happen before we're authenticated, so they silently fail until then).
  Future<void> registerCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await _updateFcmTokenUseCase(UpdateFcmTokenParams(token));
    } catch (e) {
      debugPrint('[FCM] Failed to register token: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  /// The backend stamps `recipient_type` on every push data payload, so the
  /// right screen (donor tracking vs. charity order tracking) is picked
  /// without needing to know the current session's role.
  void _navigateFromData(Map<String, dynamic> data) {
    // Not yet accepted by this charity — send it to the board to review and
    // accept, not straight to a tracking screen it doesn't own yet.
    if (data['type'] == 'new_request_available') {
      AppRouter.router.push(RouteNames.charityHome);
      return;
    }

    final donationId = int.tryParse(
      data['donation_request_id']?.toString() ?? '',
    );
    if (donationId == null) return;

    final route = data['recipient_type'] == 'charity'
        ? RouteNames.charityOrderTrackingPath(donationId)
        : RouteNames.donationDetailsPath(donationId);
    AppRouter.router.push(route);
  }
}
