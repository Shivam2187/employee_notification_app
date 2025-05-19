// ignore: unused_import
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:notification_flutter_app/core/hive_service.dart';
import 'package:notification_flutter_app/core/locator.dart';
import 'package:notification_flutter_app/presentation/providers/employee_provider.dart';
import 'package:notification_flutter_app/presentation/screens/home_draggable_scrollable_sheet.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_10y.dart';
import 'package:timezone/timezone.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
       int id=0;
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    initializeTimeZones();

    setLocalLocation(getLocation('Asia/Kolkata'));
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel_id',
          'Instant Notifications',
          channelDescription: 'Instant notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ), // AndroidNotificationDetails i0S: DarwinNotificationDetails(),
      ), // NotificationDetails
    );
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    String? body,
  }) async {
    TZDateTime now = TZDateTime.now(local);
    TZDateTime scheduledDate = now.add(
      const Duration(seconds: 3),
    );
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel_id', // A unique ID to group notifications together.
          'Daily Reminders', // A human-readable name shown to users in their notification settings.
          channelDescription: 'Reminder to complete daily habits',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ), // NotificationDetails
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime, // or dateAndTime
    );
  }

  Future<void> _onRefresh(BuildContext ctx) async {
    await ctx.read<EmployeProvider>().fetchAllTask();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Home content
          RefreshIndicator(
            onRefresh: () => _onRefresh(context),
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: SafeArea(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/login/rod.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: GestureDetector(
                                onTap: () {
                                  locator
                                      .get<HiveService>()
                                      .clearAllMobileUsersData();
                                  context.pushReplacement(
                                    '/loginPage',
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors
                                        .grey[300], // Light grey background
                                    shape: BoxShape.circle, // Makes it round
                                  ),
                                  padding: const EdgeInsets.all(
                                      8), // Padding inside the circle
                                  child: Lottie.asset(
                                    'assets/animations/logout.json',
                                    repeat: true,
                                    width: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showInstantNotification(
                                  id: id++,
                                  title: 'Title',
                                  body: 'Instant Notification');
                            },
                            child: const Text('instant notification'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              scheduleReminder(
                                  id: id++,
                                  title: 'Title',
                                  body: 'Timed Notification');
                            },
                            child: const Text('Timed notification'),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(''),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              return false; // ✅ Let scrolling continue!
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.1,
              maxChildSize: 0.85,
              builder: (context, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: HomeDraggableScrollableSheet(
                    scrollController: controller,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
