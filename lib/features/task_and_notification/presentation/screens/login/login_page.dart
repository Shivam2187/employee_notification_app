import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:notification_flutter_app/core/hive_service.dart';
import 'package:notification_flutter_app/core/locator.dart';
import 'package:notification_flutter_app/firebase/notification.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/global_store.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/top_snake_bar.dart';
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
  final _formKey = GlobalKey<FormState>();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Lottie.asset(
                  'assets/animations/welcome.json',
                  repeat: true,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.phone,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number*',
                      hintText: 'Enter Your Mobile Number*',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a valid Mobile Number';
                      }
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Enter valid 10-digit number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
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
                      if (_formKey.currentState!.validate()) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        //save mobile number to hive
                        await locator
                            .get<HiveService>()
                            .saveMobileNumber(number: _emailController.text);
                        //save mobile number to global store
                        GlobalStroe().userMobileNumber = _emailController.text;

                        /// fetch FCM token and store  in Firestore database

                        await NotificationService.fetchFmcToken();

                        // navigate to home page
                        context.pushReplacement(
                          '/',
                        );
                      } else {
                        showTopSnackBar(
                          context: context,
                          message: 'Please Enter Valid Mobile Number!',
                          bgColor: Colors.grey.shade900,
                        );
                      }
                      return false;
                    },
                  ),
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
