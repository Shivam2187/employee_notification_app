import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/loader.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/top_snake_bar.dart';
import 'package:notification_flutter_app/firebase/login_service.dart';
import 'package:notification_flutter_app/utils/extention.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = GoRouterState.of(context).extra as String?;
    emailCtrl.text = email ?? '';

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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    if (!value.contains("@")) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      bool status = false;
                      FocusScope.of(context).unfocus();
                      if ((_formKey.currentState?.validate() ?? false) &&
                          emailCtrl.text.isNotNullOrEmpty) {
                        // Call the forgot password service
                        LoaderDialog.show(context: context);
                        status = await UserAuthService()
                            .forgotEmailPassword(emailCtrl.text.trim());
                        LoaderDialog.hide(context: context);

                        context.pop();
                      }
                      showTopSnackBar(
                        context: context,
                        message: status
                            ? "Password reset email sent."
                            : "Failed to send password reset email.",
                        bgColor: status ? Colors.green : Colors.red,
                      );
                    },
                    child: const Text(
                      "Send Reset Link",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
