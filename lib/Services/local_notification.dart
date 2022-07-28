import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer' as devtools show log;

class LocalNotificationClass {
  static final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initializeFun() {
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'));

    localNotificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        'high_importance_channel',
  'High Importance Notifications',
        priority: Priority.high,
        importance: Importance.max,
      ));

      await localNotificationsPlugin.show(id, message.notification?.title,
          message.notification?.body, notificationDetails);
    } on Exception catch (e) {
      devtools.log('Exception comming from LocalNotifcation Class $e');
      // TODO
    }
  }
}
