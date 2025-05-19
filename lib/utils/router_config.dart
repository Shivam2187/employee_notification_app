import 'package:go_router/go_router.dart';
import 'package:notification_flutter_app/core/locator.dart';
import 'package:notification_flutter_app/presentation/providers/global_store.dart';
import 'package:notification_flutter_app/presentation/screens/admin_page.dart';
import 'package:notification_flutter_app/presentation/screens/admin_task_dashboard.dart';
import 'package:notification_flutter_app/presentation/screens/home_page.dart';
import 'package:notification_flutter_app/presentation/screens/login/login_page.dart';
import 'package:notification_flutter_app/presentation/widgets/task_detail_hero_page.dart';

final routerConfig = GoRouter(
  initialLocation: locator.get<GlobalStroe>().userMobileNumber?.isEmpty ?? true
      ? '/loginPage'
      : '/',
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
          onPressed: data.onPressed,
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
  ],
);
