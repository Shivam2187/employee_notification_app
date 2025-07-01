import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/selected_task_detail_with_url.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/task.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/employee_provider.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/global_store.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/screens/admin_task_dashboard.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/linkify_widget.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/loader.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/top_snake_bar.dart';
import 'package:notification_flutter_app/firebase/one_signal_notification.dart';
import 'package:notification_flutter_app/utils/extention.dart';
import 'package:shimmer/shimmer.dart';

class StaggeredTaskListViewBuilder extends StatelessWidget {
  final List<Task> displayedTaskList;
  final String imageUrl;
  final EmployeProvider employeProvider;
  final bool isTaskDeleteCall;

  const StaggeredTaskListViewBuilder({
    super.key,
    required this.displayedTaskList,
    required this.imageUrl,
    required this.employeProvider,
    this.isTaskDeleteCall = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: displayedTaskList.length,
        itemBuilder: (context, index) {
          final currentTask = displayedTaskList[index];
          final remaningDays = getRemainingDays(currentTask);
          return AnimationConfiguration.staggeredList(
            position: index,
            child: SlideAnimation(
              horizontalOffset: 200,
              duration: const Duration(milliseconds: 800),
              child: FadeInAnimation(
                duration: const Duration(milliseconds: 800),
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 8),
                    leading: Hero(
                      tag: currentTask.id ?? '',
                      flightShuttleBuilder: (flightContext, animation,
                          direction, fromContext, toContext) {
                        return Image.asset(imageUrl);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          ('#${index + 1}').toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    title: Text(
                      currentTask.employeeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinkifyWidget(
                          description: currentTask.description,
                        ),
                        Text(
                          'Due Date: ${currentTask.taskComplitionDate.toSlashDate()}',
                        ),
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
                              color: remaningDays <= 0
                                  ? Colors.red
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    trailing: IconButton(
                      icon: isTaskDeleteCall
                          ? Lottie.asset(
                              'assets/animations/delete.json',
                              repeat: true,
                              width: 50,
                              height: 50,
                            )
                          : const Icon(
                              Icons.archive_outlined,
                              color: Colors.blue,
                            ),
                      onPressed: () async {
                        if (currentTask.id == null) return;
                        // Calling Delete Task API
                        bool status = false;
                        LoaderDialog.show(context: context);
                        if (isTaskDeleteCall) {
                          status = await employeProvider.deleteTask(
                            taskId: currentTask.id!,
                          );

                          /// Cancle notification for Scheduled Notification
                          await OneSignalNotificationService()
                              .cancelScheduledNotification(
                            currentTask.notificationId,
                          );
                        } else {
                          status = await employeProvider.updateArchieveStatus(
                              taskId: currentTask.id!);
                        }
                        LoaderDialog.hide(context: context);
                        showTopSnackBar(
                          context: context,
                          message: status
                              ? 'Succesfully Operation Done'
                              : 'Failed to Operation Done',
                          bgColor: status ? Colors.green : Colors.red,
                        );
                      },
                    ),
                    onTap: () {
                      GlobalStore().selectedTaskDetailWithUrl =
                          SelectedTaskDetailWithUrl(
                        task: currentTask,
                        imageUrl: imageUrl,
                        isCompletedButtonVisible: true,
                      );
                      context.push(
                        '/taskDetailHeroPage',
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
