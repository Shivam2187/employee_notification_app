// // ignore_for_file: avoid_print

// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart';
// import 'package:notification_flutter_app/core/debug_print.dart';
// import 'package:notification_flutter_app/features/task_and_notification/data/models/task.dart';

// class FCMTokenManager {
//   // make singleton
//   FCMTokenManager._privateConstructor();
//   static final FCMTokenManager _instance =
//       FCMTokenManager._privateConstructor();
//   factory FCMTokenManager() {
//     return _instance;
//   }

//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final employeeEmailId = '6377052571';

//   // Initialize FCM and set up token listeners
//   Future<void> storeUpdatedToken(String? token) async {
//     // Get initial token
//     if (token != null) {
//       await _storeToken(employeeEmailId: employeeEmailId, token: token);
//     } else {
//       debugprint('Mobile number or token is null, cannot store token.');
//     }

//     // Listen for token refreshes
//     _firebaseMessaging.onTokenRefresh.listen((newToken) {
//       _storeToken(employeeEmailId: employeeEmailId, token: newToken);
//     });
//   }

//   // Store token in Firestore mapped to mobile number
//   Future<void> _storeToken({
//     required String employeeEmailId,
//     required String token,
//   }) async {
//     try {
//       final collection = _firestore.collection('user_fcm_token');

//       await collection.doc(employeeEmailId).set({
//         'fcm_token': token,
//         'last_updated': FieldValue.serverTimestamp(),
//         'mobile_number': employeeEmailId,
//       }, SetOptions(merge: true));

//       debugprint('FCM token stored/updated for $employeeEmailId');
//     } catch (e) {
//       debugprint('Error storing FCM token: $e');
//     }
//   }

//   // Get token for a specific mobile number
//   Future<String?> getTokenForUser(String mobileNumber) async {
//     try {
//       DocumentSnapshot doc =
//           await _firestore.collection('user_fcm_token').doc(mobileNumber).get();

//       return doc.exists ? doc['fcm_token'] : null;
//     } catch (e) {
//       debugprint('Error getting token: $e');
//       return null;
//     }
//   }

//   // Remove token when user logs out
//   Future<void> removeToken(String mobileNumber) async {
//     try {
//       await _firestore.collection('user_fcm_token').doc(mobileNumber).update({
//         'fcm_token': FieldValue.delete(),
//       });
//     } catch (e) {
//       debugprint('Error removing token: $e');
//     }
//   }

//   // Send notification when task is submitted
//   Future<void> sendTaskNotification({
//     required Task task,
//   }) async {
//     try {
//       // 1. Get recipient's FCM token
//       final token = await getTokenForUser(task.employeeMobileNumber ?? '');

//       if (token == null) {
//         debugprint('No FCM token found for user ${task.employeeMobileNumber}');
//         return;
//       }

//       // 2. Prepare notification payload
//       final payload = {
//         'notification': {
//           'title': task.employeeName,
//           'body': 'You have a new task: ${task.description}',
//           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//         },
//         'data': {
//           'type': 'task_assignment',
//           'task_id': task.id,
//           'mobile_number': task.employeeMobileNumber,
//         },
//         'to': token,
//       };

//       // 3. Send notification via FCM
//       final response = await post(
//         Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'key=YOUR_SERVER_KEY',
//         },
//         body: jsonEncode(payload),
//       );

//       if (response.statusCode == 200) {
//         debugprint('Notification sent successfully');
//       } else {
//         debugprint('Failed to send notification: ${response.body}');
//       }
//     } catch (e) {
//       debugprint('Error sending notification: $e');
//     }
//   }
// }
