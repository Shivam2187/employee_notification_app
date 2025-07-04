import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/elevetated_button_with_full_width.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/loader.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/top_snake_bar.dart';
import 'package:notification_flutter_app/firebase/login_service.dart';
import 'package:notification_flutter_app/firebase/one_signal_uid_manager.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF4F6FA),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset(
              'assets/login/register.png',
              fit: BoxFit.fill,
            ).image,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please fill the form to sign up",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email*",
                          hintText: "Enter your email",
                          prefixIcon: Icon(Icons.email_outlined),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password*",
                          hintText: "Enter your password",
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButtonWithFullWidth(
                  backgroundColor: Colors.grey.shade700,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if ((_formKey.currentState?.validate() ?? false) &&
                        emailCtrl.text.trim().isNotEmpty &&
                        passCtrl.text.trim().isNotEmpty) {
                      /// Create user with email and password
                      LoaderDialog.show(context: context);
                      final status = await UserAuthService().createUser(
                        emailCtrl.text.trim(),
                        passCtrl.text.trim(),
                      );

                      /// Store user UID that will mapped to the email ID
                      await OneSignalUidManager().storeUserUid(
                        employeeEmailId:
                            FirebaseAuth.instance.currentUser?.email ?? '',
                        uid: FirebaseAuth.instance.currentUser?.uid ?? '',
                      );

                      if (mounted) LoaderDialog.hide(context: context);
                      // navigate to home page and remove all previous routes
                      if (status) {
                        context.go('/');
                      } else {
                        showTopSnackBar(
                          context: context,
                          message: "Sign Up failed. Please try again.",
                          bgColor: Colors.red,
                        );
                      }
                    } else {
                      showTopSnackBar(
                        context: context,
                        message: "Please fill in all fields correctly.",
                        bgColor: Colors.red,
                      );
                    }
                  },
                  buttonTitle: "Sign Up",
                ),
                const SizedBox(height: 16),
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    context.pop();
                  },
                  child: const Text("Sign In"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
