import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:notification_flutter_app/core/debug_print.dart';

class OneSignalNotification {
  /// Signgleton instance of OneSignalNotification
  OneSignalNotification._privateConstructor();
  static final OneSignalNotification _instance =
      OneSignalNotification._privateConstructor();
  factory OneSignalNotification() {
    return _instance;
  }

  static String oneSignalAppId = "0764d38d-b5dd-455c-9cb4-a24755091fc1";
  static String oneSignalRestApiKey =
      "os_v2_app_a5snhdnv3vcvzhfuujdvkci7ygyw7e3dz6rus6uu55ipzkaslw6r3giuihrywm4vtcsitexmfhjvzviskpsimztprg2exeyrt5cwk4a";

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
      debugprint("Notification sent successfully!");
    } else {
      debugprint("Failed to send notification: ${response.body}");
    }
  }

// This function will schedule a notification to be sent later.
  Future<void> scheduleDueDateNotification({
    required String uid,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required Map<String, dynamic> taskIdDetails,
  }) async {
    // 2. Format the time for the OneSignal API (e.g., "yyyy-MM-dd HH:mm:ss 'GMT'Z")
    final String formattedScheduledTime =
        DateFormat("yyyy-MM-dd HH:mm:ss 'GMT'Z").format(scheduledTime.toUtc());

    // 3. Create the request body, including the new 'send_after' parameter
    final bodyData = {
      "app_id": oneSignalAppId,
      "include_external_user_ids": [uid],
      "headings": {"en": title},
      "contents": {"en": body},
      "data": {"taskIdDetails": taskIdDetails},
      "channel_for_external_user_ids": "push",
      "send_after": formattedScheduledTime, // <-- THE MAGIC PARAMETER
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
      debugprint("Notification successfully scheduled with OneSignal!");
      debugprint("Response: ${response.body}");
    } else {
      debugprint("Failed to schedule notification: ${response.body}");
    }
  }
}
