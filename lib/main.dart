import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/selected_task_detail_with_url.dart';
import 'package:notification_flutter_app/firebase/notification_service.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/user_login_info.dart';
import 'package:notification_flutter_app/utils/router_config.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:notification_flutter_app/core/locator.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/employee_provider.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/global_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await NotificationService.initializeNotification();
  FirebaseMessaging.onBackgroundMessage(
      NotificationService.firebaseMessagingBackgroundHandler);

  /// Hive Initialization
  hiveStorageinit();

  DependencyInjection.setupLocator();
  GlobalStore().init();

  initializeCrashHandler();

  runApp(const _HomePage());
}

void initializeCrashHandler() {
  const fatalError = true;
  // Non-async exceptions
  FlutterError.onError = (errorDetails) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    }
  };
  // Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
    return true;
  };
}

Future<void> hiveStorageinit() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserLoginInfoAdapter());
  await Hive.openBox<UserLoginInfo>('mobile_users');
}

Future<void> oneSignalinit() async {
  await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("0764d38d-b5dd-455c-9cb4-a24755091fc1");
  await OneSignal.Notifications.requestPermission(true);
  bool isRoutePushed = false;

  OneSignal.Notifications.addClickListener((event) {
    final Map<String, dynamic>? additionalData =
        event.notification.additionalData;

    if (additionalData == null ||
        !additionalData.containsKey('taskIdDetails')) {
      print(
          "Error: Notification clicked, but 'taskIdDetails' was not found in the payload.");
      return;
    }

    final Map<String, dynamic> taskDetailsMap =
        Map<String, dynamic>.from(additionalData['taskIdDetails']);

    final SelectedTaskDetailWithUrl taskObject =
        SelectedTaskDetailWithUrl.fromJson(taskDetailsMap);

    print(
        "Successfully parsed data. Navigating with task: ${taskObject.toString()}");

    GlobalStore().selectedTaskDetailWithUrl = taskObject;
    if (!isRoutePushed) {
      isRoutePushed = true;
      routerConfig.push('/taskDetailHeroPage');
    }
  });
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    /// OneSignal Initialization
    oneSignalinit();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => EmployeProvider(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: routerConfig,
      ),
    );
  }
}
