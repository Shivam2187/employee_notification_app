import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notification_flutter_app/core/debug_print.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalUidManager {
  static final OneSignalUidManager _instance = OneSignalUidManager._internal();

  /// Singleton instance of OneSignalUidManager
  factory OneSignalUidManager() {
    return _instance;
  }
  OneSignalUidManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create if user is new else update Existing data
  Future<void> storeUserUid({
    required String employeeEmailId,
    required String uid,
  }) async {
    try {
      await OneSignal.login(FirebaseAuth.instance.currentUser?.uid ?? '');
      final collection = _firestore.collection('user_uid');

      await collection.doc(employeeEmailId).set({
        'userUid': uid,
        'lastUpdated': FieldValue.serverTimestamp(),
        'employeeEmailId': employeeEmailId,
      }, SetOptions(merge: true));

      debugprint('User UID stored/updated for $employeeEmailId');
    } catch (e) {
      debugprint('Error storing User UID: $e');
    }
  }

  // Get UID for a specific employee email ID
  Future<String?> getUid({required String employeeEmailId}) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('user_uid').doc(employeeEmailId).get();

      return doc.exists ? doc['userUid'] : null;
    } catch (e) {
      debugprint('Error getting UID: $e');
      return null;
    }
  }
}
