import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:notification_flutter_app/features/login/presentation/screens/forgot_password_page.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/screens/admin_page.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/screens/admin_task_dashboard.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/screens/home_page.dart';
import 'package:notification_flutter_app/features/login/presentation/screens/login_page.dart';
import 'package:notification_flutter_app/features/login/presentation/screens/sign_up_page.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/task_detail_hero_page.dart';

final routerConfig = GoRouter(
  initialLocation:
      FirebaseAuth.instance.currentUser == null ? '/loginPage' : '/',
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
        final data = state.extra as TaskDetailsWithImageUrl;
        return TaskDetailHeroPage(
          imageUrl: data.imageUrl,
          task: data.task,
          isCompleyedButtonVisible: data.isCompletedButtonVisible,
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
