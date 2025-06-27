// lib/controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notification_flutter_app/core/debug_print.dart';

class UserAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get firebaseUser => _auth.currentUser;

  // Singleton pattern
  UserAuthService._privateConstructor();
  static final UserAuthService _instance =
      UserAuthService._privateConstructor();
  factory UserAuthService() {
    return _instance;
  }

  Future<bool> createUser(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      debugprint('**** Create User - ${e.toString()}');
      return false;
    }
  }

  Future<bool> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      debugprint('**** Login - ${e.toString()}');
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      debugprint('**** Sign Out - ${e.toString()}');
      return false;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // user canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugprint('****Google Sign-In failed: $e');
      return null;
    }
  }

  /// get email of the current user
  String? getCurrentUserEmail() {
    final email = firebaseUser?.email;
    debugprint('****Current User - $email');
    return email;
  }

  Future<bool> forgotEmailPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugprint('*****Forgot password failed: $e');
      return false;
    }
  }
}
