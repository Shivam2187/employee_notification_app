import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:notification_flutter_app/core/debug_print.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/global_store.dart';
import 'package:notification_flutter_app/utils/extention.dart';

class OneSignalNotificationService {
  /// Signgleton instance of OneSignalNotification
  OneSignalNotificationService._privateConstructor();
  static final OneSignalNotificationService _instance =
      OneSignalNotificationService._privateConstructor();
  factory OneSignalNotificationService() {
    return _instance;
  }

  /// create

  static String oneSignalAppId =
      GlobalStore().getSecretValue(key: 'oneSignalAppId');
  static String oneSignalRestApiKey =
      GlobalStore().getSecretValue(key: 'oneSignalRestApiKey');

  /// Send a notification to a specific user using OneSignal
  Future<void> sendNotificationToUser({
    required String uid,
    required String title,
    required String body,
    required Map<String, dynamic>
        taskIdDetails, // To handle navigation when tapped
  }) async {
    final bodyData = {
      "app_id": oneSignalAppId,
      "include_external_user_ids": [uid], // Target the specific user
      "headings": {"en": title},
      "contents": {"en": body},
      "data": {"taskIdDetails": taskIdDetails}, // Custom data for navigation
      "channel_for_external_user_ids": "push",
      "small_icon":
          "https://cdn.sanity.io/images/tqenxrzt/production/b87b6887de335dfbf3c8f3538c22bb69e53dbabd-948x1024.png",
      "large_icon":
          "https://cdn.sanity.io/images/tqenxrzt/production/b87b6887de335dfbf3c8f3538c22bb69e53dbabd-948x1024.png",
    };

    final response = await http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Basic $oneSignalRestApiKey',
      },
      body: jsonEncode(bodyData),
    );

    if (response.statusCode == 200) {
      debugprint("Instant Notification sent successfully!");
    } else {
      debugprint("Failed to send notification: ${response.body}");
    }
  }

// This function will schedule a notification to be sent later.
  Future<String?> scheduleDueDateNotification({
    required String uid,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required Map<String, dynamic> taskIdDetails,
  }) async {
    //Format the time for the OneSignal API (e.g., "yyyy-MM-dd HH:mm:ss 'GMT'Z")
    final String formattedScheduledTime =
        DateFormat("yyyy-MM-dd HH:mm:ss 'GMT'Z").format(scheduledTime.toUtc());

    //Create the request body, including the new 'send_after' parameter
    final bodyData = {
      "app_id": oneSignalAppId,
      "include_external_user_ids": [uid],
      "headings": {"en": title},
      "contents": {"en": body},
      "data": {"taskIdDetails": taskIdDetails},
      "channel_for_external_user_ids": "push",
      "send_after": formattedScheduledTime,
      "small_icon":
          "https://cdn.sanity.io/images/tqenxrzt/production/b87b6887de335dfbf3c8f3538c22bb69e53dbabd-948x1024.png",
      "large_icon":
          "https://cdn.sanity.io/images/tqenxrzt/production/b87b6887de335dfbf3c8f3538c22bb69e53dbabd-948x1024.png",
    };

    debugprint("Scheduling notification for: $formattedScheduledTime");

    final response = await http.post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Basic $oneSignalRestApiKey',
      },
      body: jsonEncode(bodyData),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final String notificationId = jsonResponse['id'];

      debugprint("Scheduled Notification Sent successfully  ${response.body}");
      return notificationId;
    } else {
      debugprint("Failed to schedule notification: ${response.body}");
      return null;
    }
  }

  /// Cancels a previously scheduled notification using its ID.
  Future<bool> cancelScheduledNotification(String? notificationId) async {
    if (notificationId.isNullOrEmpty) {
      print('⚠️ Notification ID is empty Or Null, cannot cancel.');
      return false;
    }

    final url = Uri.parse(
        'https://onesignal.com/api/v1/notifications/$notificationId?app_id=$oneSignalAppId');

    final headers = {
      'Authorization': 'Basic $oneSignalRestApiKey',
    };

    try {
      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          print(
              '✅ OneSignal notification cancelled successfully! ID: $notificationId');
          return true;
        }
      }
      print('❌ Failed to cancel OneSignal notification: ${response.body}');
      return false;
    } catch (e) {
      print('❌ Error cancelling OneSignal notification: $e');
      return false;
    }
  }
}
