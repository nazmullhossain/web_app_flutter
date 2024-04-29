import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'app/services/analytic_engin.dart';
import 'constants.dart';

class NotificationService {
  void listenNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("onMessageOpenedApp: $message");
    });
    await getToken();
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    // AndroidNotification? android = message.notification?.android;
    debugPrint("  Notification: ${message.notification?.title} ${message.notification?.body}");
    debugPrint('Notification received: ${notification?.body}');
  }

  Future<void> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken(vapidKey: Constants.vapIdKey);
    AnalyticEngin.eventLog("FCM token :: $token");
    debugPrint('FCM Token: $token');
  }
}
