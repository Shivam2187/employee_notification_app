// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/dynamic_bottomsheet.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/elevetated_button_with_full_width.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/loader.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/staggered_task_list_view_builder.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/top_snake_bar.dart';
import 'package:provider/provider.dart';

import 'package:notification_flutter_app/features/task_and_notification/data/models/task.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/employee_provider.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/fancy_appbar.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/custom_search.dart';

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
          appBar: FancyAppBar(
            title: 'Task List',
            isArchievedButtonVisible: true,
            archievedButtononTap: () => dynamicBottomsheet(
              context: context,
              contentWidget: Consumer<EmployeProvider>(
                  builder: (context, provider, child) {
                return provider.getArchivedTask.isNotEmpty
                    ? StaggeredTaskListViewBuilder(
                        displayedTaskList: provider.getArchivedTask,
                        imageUrl: imageUrl,
                        employeProvider: provider,
                        isTaskDeleteCall: true,
                      )
                    : const Center(
                        child: Text('Archived Task Empty!!'),
                      );
              }),
              stickyWidget: ElevatedButtonWithFullWidth(
                buttonTitle: 'Delete All',
                onPressed: data.getArchivedTask.isNotEmpty
                    ? () async {
                        LoaderDialog.show(context: context);
                        final status = await data.deleteAllArchievedTask(
                            taskList: data.taskList);
                        showTopSnackBar(
                          context: context,
                          message: status
                              ? 'All Archived Task Deleted Successfully'
                              : 'Failed to Delete Archived Task',
                          bgColor: status ? Colors.green : Colors.red,
                        );
                        LoaderDialog.hide(context: context);
                        context.pop(); // close the bottom sheet
                      }
                    : null,
              ),
            ),
            // No action for now
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
                  child: StaggeredTaskListViewBuilder(
                    displayedTaskList: filteredTaskList,
                    imageUrl: imageUrl,
                    employeProvider: data,
                  ),
                ),
              if (filteredTaskList.isEmpty && data.getTaskSearchQuery.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No Task Added Yet!',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              if (filteredTaskList.isEmpty &&
                  data.getTaskSearchQuery.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No Task Found with word ${data.getTaskSearchQuery}!',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
            ],
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
