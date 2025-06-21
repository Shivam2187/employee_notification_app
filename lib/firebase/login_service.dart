// lib/controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';

class UserAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? firebaseUser;

  // Singleton pattern
  UserAuthService._privateConstructor();
  static final UserAuthService _instance =
      UserAuthService._privateConstructor();
  factory UserAuthService() {
    return _instance;
  }

  void onInit() {
    firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      // User is logged in, you can access user details
      print('User is logged in: ${firebaseUser!.email}');
    } else {
      // User is not logged in
      print('No user is logged in');
    }
  }

  Future<bool> createUser(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
