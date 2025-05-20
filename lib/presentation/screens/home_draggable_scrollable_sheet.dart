import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:notification_flutter_app/core/local_notification.dart';
import 'package:notification_flutter_app/core/locator.dart';
import 'package:notification_flutter_app/data/models/task.dart';
import 'package:notification_flutter_app/presentation/providers/global_store.dart';
import 'package:notification_flutter_app/presentation/screens/admin_task_dashboard.dart';
import 'package:notification_flutter_app/presentation/widgets/admin_acess_dialog.dart';
import 'package:notification_flutter_app/presentation/widgets/carousel_slider.dart';
import 'package:notification_flutter_app/presentation/widgets/linkify_widget.dart';
import 'package:notification_flutter_app/utils/extention.dart';
import 'package:provider/provider.dart';
import 'package:notification_flutter_app/presentation/providers/employee_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timezone/timezone.dart';

class HomeDraggableScrollableSheet extends StatefulWidget {
  final ScrollController scrollController;
  const HomeDraggableScrollableSheet({
    super.key,
    required this.scrollController,
  });

  @override
  State<HomeDraggableScrollableSheet> createState() =>
      _HomeDraggableScrollableSheetState();
}

class _HomeDraggableScrollableSheetState
    extends State<HomeDraggableScrollableSheet> {
  bool _isLoading = true;
  String? _error;
  final globalStore = locator.get<GlobalStroe>();
  String? userMobileNumber;

  @override
  void initState() {
    super.initState();
    userMobileNumber = globalStore.userMobileNumber;
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      await context.read<EmployeProvider>().fetchAllTask();
      setNotificationForRemainingTask();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const String imageUrl = 'assets/login/rod_stock.jpg';

    if (_isLoading) {
      return Lottie.asset(
        'assets/animations/loading.json',
        width: double.infinity,
        height: double.infinity,
        repeat: true,
      );
    } else if (_error != null) {
      return Center(
        child: Text(
          'Something went wrong!\n$_error',
        ),
      );
    } else {
      return Consumer<EmployeProvider>(
        builder: (context, provider, _) {
          final filteredTasks = provider.getFilteredAndSortedTask(
            userMobileNumber: userMobileNumber ?? '',
          );

          if (filteredTasks.isEmpty) {
            return const Center(
              child: Text('No notifications yet.'),
            );
          }

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: ListView(
              padding: const EdgeInsets.all(8),
              controller: widget.scrollController,
              children: [
                const ArrowDownWidget(),
                const SizedBox(
                  height: 16,
                ),
                const AutoCarouselSlider(),
                const SizedBox(
                  height: 16,
                ),
                AnimationLimiter(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredTasks.length,
                    padding: const EdgeInsets.only(bottom: 32),
                    itemBuilder: (ctx, index) {
                      final currentTask = filteredTasks[index];
                      final remaningDays = getRemainingDays(currentTask);
                      final taskConfig = taskStatusConfigFunction(
                          remainingDay: remaningDays,
                          isTaskCompleted: currentTask.isTaskCompleted);

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        child: SlideAnimation(
                          horizontalOffset: 200,
                          duration: const Duration(milliseconds: 800),
                          child: FadeInAnimation(
                            duration: const Duration(milliseconds: 800),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  ListTile(
                                    trailing: AnimateIcon(
                                      color: Colors.grey.shade800,
                                      onTap: () {
                                        context.push(
                                          '/taskDetailHeroPage',
                                          extra: TaskDetailsWithImageUrl(
                                            task: currentTask,
                                            imageUrl: imageUrl,
                                          ),
                                        );
                                      },
                                      iconType: IconType.continueAnimation,
                                      width: 24,
                                      animateIcon: AnimateIcons.eye,
                                    ),
                                    contentPadding: const EdgeInsets.all(8),
                                    leading: Hero(
                                      tag: currentTask.id ?? '' 'drag',
                                      flightShuttleBuilder: (flightContext,
                                          animation,
                                          direction,
                                          fromContext,
                                          toContext) {
                                        return Image.asset(
                                          imageUrl,
                                          height: 20,
                                          width: 20,
                                        );
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Colors.blueAccent,
                                        child: Text(
                                          currentTask.employeeName
                                              .getInitials(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      currentTask.employeeName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (currentTask
                                            .description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          LinkifyWidget(
                                            description:
                                                currentTask.description,
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Text(
                                          'Due Date : ${currentTask.taskComplitionDate.toSlashDate()}',
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                        const SizedBox(height: 4),
                                        if (!currentTask.isTaskCompleted)
                                          Shimmer.fromColors(
                                            baseColor: remaningDays <= 0
                                                ? Colors.red
                                                : remaningDays == 1
                                                    ? Colors.blue
                                                    : Colors.grey.shade600,
                                            highlightColor: Colors.white,
                                            child: Text(
                                              remaningDays <= 0
                                                  ? 'Overdue'
                                                  : remaningDays == 1
                                                      ? 'Due Today'
                                                      : '$remaningDays days left',
                                              style: TextStyle(
                                                color: remaningDays <= 1
                                                    ? Colors.red
                                                    : Colors.grey.shade600,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    onTap: () {
                                      context.push(
                                        '/taskDetailHeroPage',
                                        extra: TaskDetailsWithImageUrl(
                                          task: currentTask,
                                          imageUrl: imageUrl,
                                        ),
                                      );
                                    },
                                  ),
                                  TaskStatusTag(taskConfig: taskConfig)
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => showAdminAcessDialog(context),
              icon: const Icon(Icons.admin_panel_settings_sharp),
              label: Shimmer.fromColors(
                  baseColor: Colors.black,
                  highlightColor: Colors.white,
                  child: const Text('Admin Access')),
            ),
          );
        },
      );
    }
  }

  int getRemainingDays(Task currentTask) {
    final now = DateTime.now();
    final dateOnly = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime.parse(currentTask.taskComplitionDate);

    final remaingDays = taskDate.difference(dateOnly).inDays + 1;

    return remaingDays;
  }

  TaskStatusConfig taskStatusConfigFunction({
    required int remainingDay,
    bool isTaskCompleted = false,
  }) {
    if (isTaskCompleted) {
      return TaskStatusConfig(
        backGroundColor: Colors.green,
        text: 'Completed',
      );
    }
    if (remainingDay <= 0) {
      return TaskStatusConfig(
        backGroundColor: Colors.red,
        text: 'Pending',
      );
    } else {
      return TaskStatusConfig(
        backGroundColor: Colors.grey,
        text: 'In Progress',
      );
    }
  }

// add notification  for task
  Future<void> setNotificationForRemainingTask() async {
    // add notification for remaining task
    if (globalStore.needToAddNotification) {
      final filteredTasks =
          context.read<EmployeProvider>().getFilteredAndSortedTask(
                userMobileNumber: userMobileNumber ?? '',
              );
      // Cancel all pendingNotification notifications
      await LocalNotification.cancelAllNotification();

      for (var task in filteredTasks) {
        final taskDate = DateTime.parse(task.taskComplitionDate);
        final currentDate = DateTime.now();
        final remainingDays = taskDate.difference(currentDate).inDays;
        if (remainingDays >= 0 && !task.isTaskCompleted) {
          //Object creation to pass in  LocalNotification payload
          final taskDetailsWithImageUrl = TaskDetailsWithImageUrl(
            task: task,
            imageUrl: 'assets/login/rod_stock.jpg',
          );

          final payload = taskDetailsWithImageUrl.toString();

          // Schedule a local notification
          await LocalNotification.scheduleReminder(
            id: LocalNotification.notificationId++,
            title: task.employeeName,
            body: task.description,
            payload: payload,
            scheduledDate: TZDateTime(
              local,
              taskDate.year,
              taskDate.month,
              taskDate.day,
              10,
              0,
            ),
          );
        }
      }
      globalStore.needToAddNotification = false;
    }
    // Stting up 9 AM notification every Day
    await LocalNotification.scheduleDaily9AMNotification();
    // See all pendingNotification notifications
    await LocalNotification.pendingNotification();
  }
}

class ArrowDownWidget extends StatelessWidget {
  const ArrowDownWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300], // Light grey background
        shape: BoxShape.circle, // Makes it round
      ),
      padding: const EdgeInsets.all(4), // Padding inside the circle
      child: Lottie.asset(
        'assets/animations/down_arrow.json',
        height: 32,
        width: 32,
        repeat: true,
      ),
    );
  }
}

class TaskStatusTag extends StatelessWidget {
  const TaskStatusTag({
    super.key,
    required this.taskConfig,
  });

  final TaskStatusConfig taskConfig;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: 0,
      child: Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.only(topRight: Radius.circular(12)),
            color: taskConfig.backGroundColor,
          ),
          child: Text(
            taskConfig.text,
            style: TextStyle(
              color: taskConfig.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class TaskStatusConfig {
  final Color? textColor;
  final String text;
  final Color backGroundColor;

  TaskStatusConfig({
    this.textColor = Colors.white,
    required this.text,
    required this.backGroundColor,
  });
}
