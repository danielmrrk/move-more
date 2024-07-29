import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/domain/network/dio_provider.dart';

const kDeviceTokenAlreadyRegisteredErrorName = "TECHNICAL_DEVICE_TOKEN_ALREADY_REGISTERED";

final pushNotificationService = PushNotificationService();

class PushNotificationService {
  void setupPushNotifications() async {
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      announcement: true,
      sound: true,
    );
    if (result.authorizationStatus != AuthorizationStatus.authorized && result.authorizationStatus != AuthorizationStatus.provisional) {
      return;
    }
    final deviceToken = await FirebaseMessaging.instance.getToken();
    if (deviceToken == null) {
      return;
    }
    await _registerDeviceToken(deviceToken);

    _setupAppleForgroundPushNotifications();
    _setupAndroidForgroundPushNotifications();
  }

  Future<bool> _registerDeviceToken(String token) async {
    try {
      await dio.post('/notification/token', data: {"token": token});
      return true;
    } on ApiException catch (e) {
      if (e.message == kDeviceTokenAlreadyRegisteredErrorName) {
        return false;
      }
      rethrow;
    }
  }

  void _setupAppleForgroundPushNotifications() {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, sound: true);
  }

  void _setupAndroidForgroundPushNotifications() {
    const androidNotificationChannel = AndroidNotificationChannel(
      kAndroidNotificationChannelId,
      kAndroidNotificationChannelName,
      importance: Importance.defaultImportance,
    );
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = notification?.android;

      if (notification == null || androidNotification == null) {
        return;
      }
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            kAndroidNotificationChannelId,
            kAndroidNotificationChannelName,
            playSound: true,
            icon: 'mipmap/ic_launcher',
          ),
        ),
      );
    });
  }
}
