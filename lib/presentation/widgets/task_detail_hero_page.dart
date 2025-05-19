import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notification_flutter_app/data/models/task.dart';
import 'package:notification_flutter_app/presentation/widgets/loader.dart';
import 'package:notification_flutter_app/presentation/widgets/top_snake_bar.dart';
import 'package:notification_flutter_app/utils/extention.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailHeroPage extends StatefulWidget {
  final String imageUrl;
  final Task task;
  final bool isCompleyedButtonVisible;
  final Future<bool> Function()? onPressed;

  const TaskDetailHeroPage({
    super.key,
    required this.imageUrl,
    required this.task,
    this.isCompleyedButtonVisible = false,
    this.onPressed,
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
                  tag: widget.task.id ?? '',
                  child: Image.asset(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              title: const Text('Task Details'),
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
                  _detailRow(
                      Icons.person, 'Assigned To:', widget.task.employeeName),
                  const SizedBox(height: 16),
                  _detailRow(Icons.description, 'Description:',
                      widget.task.description),
                  const SizedBox(height: 16),
                  _detailRow(
                    Icons.calendar_today,
                    'Due Date:',
                    widget.task.taskComplitionDate.toSlashDate(),
                  ),
                  const SizedBox(height: 16),
                  if (widget.task.locationLink?.isNotEmpty ?? false) ...[
                    _locationRow(context, widget.task.locationLink!),
                    const SizedBox(height: 16),
                  ],
                  if (widget.isCompleyedButtonVisible)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (widget.task.isTaskCompleted ||
                                isTaskCompleted)
                            ? null
                            : () async {
                                LoaderDialog.show(context: context);
                                final status = widget.onPressed != null
                                    ? await widget.onPressed!()
                                    : false;
                                LoaderDialog.hide(context: context);

                                setState(() {
                                  if (status) {
                                    isTaskCompleted = true;
                                  }
                                });
                                showTopSnackBar(
                                  context: context,
                                  message: status
                                      ? 'Task marked as completed!'
                                      : 'Failed to marked as completed!',
                                  bgColor: status ? Colors.green : Colors.red,
                                );
                              },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark as Completed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
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
