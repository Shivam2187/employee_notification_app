import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notification_flutter_app/features/login/presentation/screens/forgot_password_page.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/global_store.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/screens/admin_page.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/screens/home_page.dart';
import 'package:notification_flutter_app/features/login/presentation/screens/login_page.dart';
import 'package:notification_flutter_app/features/login/presentation/screens/sign_up_page.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/task_detail_hero_page.dart';

final routerKey = GlobalKey<NavigatorState>();
final routerConfig = GoRouter(
  initialLocation:
      FirebaseAuth.instance.currentUser == null ? '/loginPage' : '/',
  navigatorKey: routerKey,
  routes: [
    GoRoute(
      name:
          'HomePage', // Optional, add name to your routes. Allows you navigate by name instead of path
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: 'TaskDetailHeroPage',
      path: '/taskDetailHeroPage',
      builder: (context, state) {
        final data = GlobalStore().selectedTaskDetailWithUrl;
        if (data == null) {
          return const Scaffold(
            body: Center(
              child: Text('OOPS! Something went wrong'),
            ),
          );
        }

        return TaskDetailHeroPage(
          selectedTaskDetailWithUrl: data,
        );
      },
    ),
    GoRoute(
      name: 'LoginPage',
      path: '/loginPage',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      name: 'AdminPage',
      path: '/adminPage',
      builder: (context, state) => const AdminPage(),
    ),
    GoRoute(
      name: 'SignUpScreen',
      path: '/signUpScreen',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      name: 'ForgotPasswordPage',
      path: '/forgotPasswordPage',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
  ],
);
