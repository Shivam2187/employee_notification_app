// ignore_for_file: avoid_print

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_flutter_app/firebase/fmc_token_manager.dart';

// class LocalNotification {
//   static const String channelId = 'your_channel_id';
//   static const String channelName = 'your_channel_name';
//   static const String channelDescription = 'your_channel_description';

//   static int notificationId = 0;

//   static final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> init() async {
//     initializeTimeZones();

//     setLocalLocation(getLocation('Asia/Kolkata'));

//     const androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings();

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await notificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: onNotificationTap,
//       onDidReceiveBackgroundNotificationResponse: onNotificationTap,
//     );
//   }

//   static final onClickNotification = BehaviorSubject<String>();

//   /// on Notification tap
//   static void onNotificationTap(NotificationResponse notificationResponse) {
//     if (notificationResponse.payload != null) {
//       onClickNotification.add(notificationResponse.payload!);
//     }
//   }

//   static Future<void> scheduleReminderForTask({
//     required int id,
//     required String title,
//     required String body,
//     required TZDateTime scheduledDate,
//     required String payload,
//     int? day,
//   }) async {
//     await notificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduledDate,
//       payload: payload,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_reminder_channel_id', // A unique ID to group notifications together.
//           'Daily Reminders', // A human-readable name shown to users in their notification settings.
//           channelDescription: 'Reminder to complete daily habits',
//           ticker: 'ticker',
//           playSound: true,

//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//         iOS: DarwinNotificationDetails(),
//       ), // NotificationDetails
//       androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
//       // or dateAndTime
//     );
//   }

//   static Future<void> scheduleDaily8AMNotification() async {
//     final TZDateTime now = TZDateTime.now(local);

//     //Set to next 8 AM
//     TZDateTime scheduledDate =
//         TZDateTime(local, now.year, now.month, now.day, 8, 0, 0);
//     // Set the time to 8 AM today (or tomorrow if it's already past 8 AM)
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }

//     await notificationsPlugin.zonedSchedule(
//       200,
//       'Good Morning Sir!',
//       'Please Look into your daily tasks.',
//       scheduledDate,
//       payload: '',
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'daily_channel_id',
//           'Daily Notifications',
//           channelDescription: 'Notifies daily at 9 AM',
//           importance: Importance.max,
//           priority: Priority.high,
//         ),
//         iOS: DarwinNotificationDetails(),
//       ),
//       androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.time, // 🔁 repeat daily
//     );
//   }

//   static Future<void> cancelAllNotification() async {
//     await notificationsPlugin.cancelAll();
//   }

//   static Future<void> pendingNotification() async {
//     final pendingNotifications =
//         await notificationsPlugin.pendingNotificationRequests();

//     for (var element in pendingNotifications) {
//       print('Pending Notification: ${element.payload.toString()}');
//     }
//   }
// }

class NotificationService {
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize the notification service
  static Future<void> initializeNotification() async {
    await _firebaseMessaging.requestPermission();

    /// Called when message is recieved in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          '******** Received a message while in the foreground: ${message.messageId}');
      _showFlutterNotication(message);
    });

    /// Called when app is brought to foreground from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          '****** Called when app is brought to foreground from background: ${message.messageId}');
      _showFlutterNotication(message);
    });

    /// Initialize the local notification
    await _initializeLocalNotification();

    /// Get the initial notification
    await _getInitialNotification();

    fetchFmcToken();
  }

  ///  Handle background messages
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
    print('*********** Handling a background message: ${message.messageId}');
    if (message.notification == null && message.data.isNotEmpty) {
      _initializeLocalNotification();
      _showFlutterNotication(message);
    }
  }

  /// Get the FCM token

  static Future<void> fetchFmcToken() async {
    String? token = await _firebaseMessaging.getToken() ?? '';

    await FCMTokenManager().storeUpdatedToken(token);

    print('********* FCM Token: $token');
  }

  static void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    // Handle notification on tap
    print(
      '********* Notification tapped with payload: ${notificationResponse.payload}',
    );
    if (notificationResponse.payload != null) {
      // You can handle the payload here, e.g., navigate to a specific screen
      // based on the payload data.
      // For example:
      // Navigator.pushNamed(context, '/your_route', arguments: notificationResponse.payload);
    }
  }

  static Future<void> _showFlutterNotication(
    RemoteMessage message,
  ) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data['payload'],
    );
  }

  /// initialize the local notification and show notification
  static Future<void> _initializeLocalNotification() async {
    const androidInitializationSettings =
        AndroidInitializationSettings('@drawable/notification_icon');

    const iOSInitializationSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  /// Handle tap when app is terminated
  static Future<void> _getInitialNotification() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print('A new onMessageOpenedApp event was published!');
      // _showFlutterNotication(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      //_showFlutterNotication(message);
    });
  }
}
