import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:notification_flutter_app/features/login/presentation/widgets/google_sign_in_button.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/loader.dart';
import 'package:notification_flutter_app/firebase/login_service.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/top_snake_bar.dart';
import 'package:notification_flutter_app/firebase/one_signal_uid_manager.dart';
import 'package:slider_button/slider_button.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset(
              'assets/login/login.png',
              fit: BoxFit.fill,
            ).image,
          ),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/welcome.json',
                  repeat: true,
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
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
                          if (!value.contains("@")) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push(
                        '/forgotPasswordPage',
                        extra: _emailController.text.trim(),
                      );
                    },
                    child: const Text("Forgot Password?"),
                  ),
                ),
                Center(
                  child: SliderButton(
                    buttonColor: Colors.grey.shade700,
                    vibrationFlag: true,
                    label: Text(
                      "Slide to Sign In!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    action: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if ((_formKey.currentState?.validate() ?? false) &&
                          _emailController.text.trim().isNotEmpty &&
                          _passwordController.text.trim().isNotEmpty) {
                        LoaderDialog.show(context: context);
                        // call login service
                        final status =
                            await UserAuthService().loginWithEmailAndPassword(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );

                        /// Store the FCM token and user UID
                        await OneSignalUidManager().storeUserUid(
                          employeeEmailId:
                              FirebaseAuth.instance.currentUser?.email ?? '',
                          uid: FirebaseAuth.instance.currentUser?.uid ?? '',
                        );

                        if (mounted) LoaderDialog.hide(context: context);

                        // navigate to home page and remove all previous routes
                        if (status) {
                          context.go('/');
                        }
                        showTopSnackBar(
                          context: context,
                          message: status
                              ? "Login successful!"
                              : "Login failed. Please try again.",
                          bgColor: status ? Colors.green : Colors.red,
                        );
                        return true;
                      } else {
                        showTopSnackBar(
                          context: context,
                          message: "Please fill in all fields correctly.",
                          bgColor: Colors.red,
                        );
                      }

                      return false;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    context.push('/signUpScreen');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  child: const Text("Sign Up"),
                ),
                GoogleLoginButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    ///Login with Google
                    LoaderDialog.show(context: context);
                    final userData = await UserAuthService().signInWithGoogle();

                    /// Store user UID that will mapped to the email ID
                    await OneSignalUidManager().storeUserUid(
                      employeeEmailId:
                          FirebaseAuth.instance.currentUser?.email ?? '',
                      uid: FirebaseAuth.instance.currentUser?.uid ?? '',
                    );
                    LoaderDialog.hide(context: context);

                    if (userData != null) {
                      context.go('/');
                    } else {
                      showTopSnackBar(
                        context: context,
                        message: "Google Sign In failed. Please try again.",
                        bgColor: Colors.red,
                      );
                    }
                  },
                ),
                Lottie.asset(
                  'assets/animations/dancing.json',
                  repeat: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
