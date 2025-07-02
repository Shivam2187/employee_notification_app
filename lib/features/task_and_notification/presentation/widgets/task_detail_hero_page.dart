import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/selected_task_detail_with_url.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/employee_provider.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/screens/admin_task_allocation_dashboard.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/elevetated_button_with_full_width.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/loader.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/top_snake_bar.dart';
import 'package:notification_flutter_app/utils/extention.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailHeroPage extends StatefulWidget {
  final SelectedTaskDetailWithUrl selectedTaskDetailWithUrl;

  const TaskDetailHeroPage({
    super.key,
    required this.selectedTaskDetailWithUrl,
  });

  @override
  State<TaskDetailHeroPage> createState() => _TaskDetailHeroPageState();
}

class _TaskDetailHeroPageState extends State<TaskDetailHeroPage> {
  bool isTaskCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Collapsing app bar with hero image
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: MediaQuery.of(context).size.height * 0.45,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(48),
                ),
                child: Hero(
                  tag: widget.selectedTaskDetailWithUrl.task.id ?? '',
                  child: Image.asset(
                    widget.selectedTaskDetailWithUrl.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              collapseMode: CollapseMode.parallax,
            ),
          ),

          // Task info body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(context, "Task Details"),
                  const SizedBox(height: 16),
                  _detailRow(
                      Icons.report_gmailerrorred, 'Report To:', 'Manager'),
                  const SizedBox(height: 16),
                  _detailRow(Icons.person, 'Assigned To:',
                      widget.selectedTaskDetailWithUrl.task.employeeName),
                  const SizedBox(height: 16),
                  _detailRow(Icons.description, 'Description:',
                      widget.selectedTaskDetailWithUrl.task.description),
                  const SizedBox(height: 16),
                  _detailRow(
                    Icons.calendar_today,
                    'Due Date:',
                    widget.selectedTaskDetailWithUrl.task.taskComplitionDate
                        .toSlashDate(),
                  ),
                  const SizedBox(height: 16),
                  if (widget.selectedTaskDetailWithUrl.task.locationLink
                          ?.isNotEmpty ??
                      false) ...[
                    _locationRow(context,
                        widget.selectedTaskDetailWithUrl.task.locationLink!),
                    const SizedBox(height: 16),
                  ],
                  if (widget.selectedTaskDetailWithUrl.isCompletedButtonVisible)
                    ElevatedButtonWithFullWidth(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    AdminTaskAllocationDashboard(
                              editTask: widget.selectedTaskDetailWithUrl.task,
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              final tween = Tween(begin: 0.0, end: 1.0);
                              return FadeTransition(
                                opacity: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      icon: Icons.edit,
                      buttonTitle: 'Edit Task',
                    ),
                  const SizedBox(height: 8),
                  if (widget.selectedTaskDetailWithUrl.isCompletedButtonVisible)
                    ElevatedButtonWithFullWidth(
                      icon: Icons.check_circle_outline,
                      buttonTitle: 'Mark Task as Completed',
                      onPressed: (widget.selectedTaskDetailWithUrl.task
                                  .isTaskCompleted ||
                              isTaskCompleted)
                          ? null
                          : () async {
                              LoaderDialog.show(context: context);
                              final status = await context
                                  .read<EmployeProvider>()
                                  .updateTaskStatus(
                                      taskId: widget.selectedTaskDetailWithUrl
                                              .task.id ??
                                          '');
                              LoaderDialog.hide(context: context);
                              showTopSnackBar(
                                context: context,
                                message: status
                                    ? 'Task Marked as Completed'
                                    : 'Failed to update Task status',
                                bgColor: status ? Colors.green : Colors.red,
                              );

                              setState(() {
                                if (status) {
                                  isTaskCompleted = true;
                                }
                              });
                            },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$title\n',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _locationRow(BuildContext context, String locationLink) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on, color: Colors.teal),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse(locationLink);
              final canLaunch = await canLaunchUrl(url);
              if (canLaunch) {
                await launchUrl(url);
              } else {
                showTopSnackBar(
                  context: context,
                  message: 'Invalid location link!',
                );
              }
            },
            child: Text(
              locationLink,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
