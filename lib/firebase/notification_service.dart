import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_flutter_app/core/debug_print.dart';
import 'package:notification_flutter_app/firebase/fmc_token_manager.dart';

class NotificationService {
  // singleton pattern
  NotificationService._privateConstructor();
  static final NotificationService _instance =
      NotificationService._privateConstructor();
  factory NotificationService() {
    return _instance;
  }
  static final flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize the notification service
  static Future<void> initializeNotification() async {
    await _firebaseMessaging.requestPermission();

    /// Called when message is recieved in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugprint(
          '******** Received a message while in the foreground: ${message.messageId}');
      _showFlutterNotication(message);
    });

    /// Called when app is brought to foreground from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugprint(
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
    debugprint(
        '*********** Handling a background message: ${message.messageId}');
    if (message.notification == null && message.data.isNotEmpty) {
      _initializeLocalNotification();
      _showFlutterNotication(message);
    }
  }

  /// Get the FCM token

  static Future<void> fetchFmcToken() async {
    String? token = await _firebaseMessaging.getToken() ?? '';

    await FCMTokenManager().storeUpdatedToken(token);

    debugprint('********* FCM Token: $token');
  }

  static void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    // Handle notification on tap
    debugprint(
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

  /// Handle tap when app is terminate_td
  static Future<void> _getInitialNotification() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      debugprint('A new onMessageOpenedApp event was published!');
      // _showFlutterNotication(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugprint('A new onMessageOpenedApp event was published!');
      //_showFlutterNotication(message);
    });
  }
}
