// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notification_flutter_app/data/models/task.dart';
import 'package:notification_flutter_app/presentation/providers/global_store.dart';
import 'package:http/http.dart' as http;
import 'package:notification_flutter_app/utils/extention.dart';

class FCMTokenManager {
  // make singleton
  FCMTokenManager._privateConstructor();
  static final FCMTokenManager _instance =
      FCMTokenManager._privateConstructor();
  factory FCMTokenManager() {
    return _instance;
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final mobileNumber = GlobalStroe().userMobileNumber;

  // Initialize FCM and set up token listeners
  Future<void> storeUpdatedToken(String? token) async {
    // Get initial token
    if (token != null && mobileNumber != null) {
      await _storeToken(mobileNumber: mobileNumber!, token: token);
    } else {
      print('Mobile number or token is null, cannot store token.');
    }

    // Listen for token refreshes
    if (mobileNumber != null) {
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _storeToken(mobileNumber: mobileNumber!, token: newToken);
      });
    }
  }

  // Store token in Firestore mapped to mobile number
  Future<void> _storeToken({
    required String mobileNumber,
    required String token,
  }) async {
    try {
      final collection = _firestore.collection('user_fcm_token');

      await collection.doc(mobileNumber).set({
        'fcm_token': token,
        'last_updated': FieldValue.serverTimestamp(),
        'mobile_number': mobileNumber,
      }, SetOptions(merge: true));

      print('FCM token stored/updated for $mobileNumber');
    } catch (e) {
      print('Error storing FCM token: $e');
    }
  }

  // Get token for a specific mobile number
  Future<String?> getTokenForUser(String mobileNumber) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('user_fcm_token').doc(mobileNumber).get();

      return doc.exists ? doc['fcm_token'] : null;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Remove token when user logs out
  Future<void> removeToken(String mobileNumber) async {
    try {
      await _firestore.collection('user_fcm_token').doc(mobileNumber).update({
        'fcm_token': FieldValue.delete(),
      });
    } catch (e) {
      print('Error removing token: $e');
    }
  }

  // Send notification when task is submitted
  Future<void> sendTaskNotification({
    required  Task task,
  }) async {
    try {
      // 1. Get recipient's FCM token
      final token = await getTokenForUser(task.mobileNumber);

      if (token.isNullOrEmpty) {
        print('No FCM token found for user ${task.mobileNumber}');
        return;
      }

      // 2. Prepare notification payload
      final payload = {
        'notification': {
          'title': task.employeeName,
          'body': 'You have a new task: ${task.description}',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'data': {
          'type': 'task_assignment',
          'task_id': task.id,
          'mobile_number': task.mobileNumber,
        },
        'to': token,
      };

      // 3. Send notification via FCM
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_SERVER_KEY',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
