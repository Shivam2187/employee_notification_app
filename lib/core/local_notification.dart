import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/timezone.dart';

class LocalNotification {
  static const String channelId = 'your_channel_id';
  static const String channelName = 'your_channel_name';
  static const String channelDescription = 'your_channel_description';

  static int notificationId = 0;

  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    initializeTimeZones();

    setLocalLocation(getLocation('Asia/Kolkata'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  static final onClickNotification = BehaviorSubject<String>();

  /// on Notification tap
  static void onNotificationTap(NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null) {
      onClickNotification.add(notificationResponse.payload!);
    }
  }

  static Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required TZDateTime scheduledDate,
    required String payload,
    int? day,
  }) async {
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      payload: payload,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel_id', // A unique ID to group notifications together.
          'Daily Reminders', // A human-readable name shown to users in their notification settings.
          channelDescription: 'Reminder to complete daily habits',
          ticker: 'ticker',
          playSound: true,

          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ), // NotificationDetails
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime, // or dateAndTime
    );
  }

  static Future<void> scheduleDaily9AMNotification() async {
    final TZDateTime now = TZDateTime.now(local);

    // Set to next 9 AM
    TZDateTime scheduledDate = TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      9,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await notificationsPlugin.zonedSchedule(
      -1,
      'Good Morning Sir!',
      'Please Look into your daily tasks.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel_id',
          'Daily Notifications',
          channelDescription: 'Notifies daily at 9 AM',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // 🔁 repeat daily
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelAllNotification() async {
    await notificationsPlugin.cancelAll();
  }

  static Future<void> pendingNotification() async {
    final pendingNotifications =
        await notificationsPlugin.pendingNotificationRequests();

    for (var element in pendingNotifications) {
      print('Pending Notification: ${element.payload.toString()}');
    }
  }
}
