import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:notification_flutter_app/data/models/task.dart';
import 'package:notification_flutter_app/presentation/providers/employee_provider.dart';
import 'package:notification_flutter_app/presentation/widgets/appbar.dart';
import 'package:notification_flutter_app/presentation/widgets/linkify_widget.dart';
import 'package:notification_flutter_app/presentation/widgets/loader.dart';
import 'package:notification_flutter_app/presentation/widgets/custom_search.dart';
import 'package:notification_flutter_app/presentation/widgets/top_snake_bar.dart';
import 'package:notification_flutter_app/utils/extention.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AdminTaskDashboard extends StatelessWidget {
  const AdminTaskDashboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const String imageUrl = 'assets/login/rod_stock.jpg';
    return Consumer<EmployeProvider>(
      builder: (context, data, child) {
        final filteredTaskList = data.getFilteredTask;

        return Scaffold(
          appBar: const FancyAppBar(
            title: 'Task List',
          ),
          body: Column(
            children: [
              CustomSearchBar(
                hinText: 'Search Task by Employee Name',
                onChanged: (value) {
                  data.setTaskSearchQuery(value);
                },
                initialText: data.getTaskSearchQuery,
              ),
              if (filteredTaskList.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: filteredTaskList.length,
                    itemBuilder: (context, index) {
                      final currentTask = filteredTaskList[index];
                      final remaningDays = getRemainingDays(currentTask);
                      return Card(
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
                              fontSize: 16,
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
                            icon: Lottie.asset(
                              'assets/animations/delete.json',
                              repeat: true,
                              width: 50,
                              height: 50,
                            ),
                            onPressed: () async {
                              if (currentTask.id == null) return;
                              // Calling Delete Task API
                              LoaderDialog.show(context: context);
                              final status = await data.deleteTask(
                                  taskId: currentTask.id!);
                              LoaderDialog.hide(context: context);
                              showTopSnackBar(
                                context: context,
                                message: status
                                    ? 'Succesfully deleted'
                                    : 'Failed to delete',
                                bgColor: status ? Colors.green : Colors.red,
                              );
                            },
                          ),
                          onTap: () {
                            context.push(
                              '/taskDetailHeroPage',
                              extra: TaskDetailsWithImageUrl(
                                task: currentTask,
                                imageUrl: imageUrl,
                                isCompletedButtonVisible: true,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              // if (filteredTaskList.isEmpty) ...[
              //   const SizedBox(height: 20),
              //   Lottie.asset(
              //     'assets/animations/noData.json',
              //     repeat: true,
              //     width: 200,
              //     height: 200,
              //   ),
              //   const SizedBox(height: 20),
              // ],
              if (filteredTaskList.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No Task Found with word "${data.getTaskSearchQuery}"',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  int getRemainingDays(Task currentTask) {
    final now = DateTime.now();
    final dateOnly = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime.parse(currentTask.taskComplitionDate);

    final remaingDays = taskDate.difference(dateOnly).inDays + 1;

    return remaingDays;
  }
}

class TaskDetailsWithImageUrl {
  final Task task;
  final String imageUrl;
  final bool isCompletedButtonVisible;

  TaskDetailsWithImageUrl({
    this.isCompletedButtonVisible = false,
    required this.task,
    required this.imageUrl,
  });

  // Convert object to JSON Map
  Map<String, dynamic> toJson() => {
        'task': task.toJson(),
        'imageUrl': imageUrl,
        'isCompletedButtonVisible': isCompletedButtonVisible,
      };

  // Convert object to String
  @override
  String toString() => jsonEncode(toJson());

  // Create object from JSON Map
  factory TaskDetailsWithImageUrl.fromJson(Map<String, dynamic> json) {
    return TaskDetailsWithImageUrl(
      task: Task.fromJson(json['task']),
      imageUrl: json['imageUrl'],
      isCompletedButtonVisible: json['isCompletedButtonVisible'] ?? false,
    );
  }

  // Create object from String
  factory TaskDetailsWithImageUrl.fromString(String str) =>
      TaskDetailsWithImageUrl.fromJson(jsonDecode(str));
}
