import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/elevetated_button_with_full_width.dart';
import 'package:provider/provider.dart';

import 'package:notification_flutter_app/features/task_and_notification/data/models/employee.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/selected_task_detail_with_url.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/task.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/employee_provider.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/fancy_appbar.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/loader.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/top_snake_bar.dart';
import 'package:notification_flutter_app/firebase/one_signal_notification_service.dart';
import 'package:notification_flutter_app/firebase/one_signal_uid_manager.dart';

class AdminTaskAllocationDashboard extends StatefulWidget {
  final Task? editTask;
  const AdminTaskAllocationDashboard({
    super.key,
    this.editTask,
  });

  @override
  State<AdminTaskAllocationDashboard> createState() =>
      _AdminTaskAllocationDashboardState();
}

class _AdminTaskAllocationDashboardState
    extends State<AdminTaskAllocationDashboard> {
  Employee? selectedEmployee;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationLinkController = TextEditingController();
  final TextEditingController datePickerController = TextEditingController();

  DateTime? pickedDate;

  @override
  void initState() {
    super.initState();
    preFillData();
  }

  /// for edit task not for new task
  void preFillData() {
    if (widget.editTask == null) return;
    descriptionController.text = widget.editTask!.description;
    locationLinkController.text = widget.editTask!.locationLink ?? '';
    datePickerController.text = widget.editTask!.taskComplitionDate;
    selectedEmployee = Employee(
      employeeName: widget.editTask!.employeeName,
      employeeEmailId: widget.editTask!.employeeEmailId,
      employeeMobileNumber: widget.editTask!.employeeMobileNumber,
      description: widget.editTask!.description,
    );
    pickedDate = DateTime.parse(widget.editTask!.taskComplitionDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // earliest allowed date
      lastDate: DateTime(2100), // latest allowed date
    );

    if (pickedDate != null) {
      setState(() {
        datePickerController.text =
            "${pickedDate!.day}/${pickedDate!.month}/${pickedDate!.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeProvider = Provider.of<EmployeProvider>(context);
    final remaingDays =
        pickedDate != null ? pickedDate!.difference(DateTime.now()).inDays : {};

    return Scaffold(
      appBar: const FancyAppBar(title: 'Assign Task'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Employee*'),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.shade100),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Employee>(
                      value: selectedEmployee,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.indigo,
                        size: 28,
                      ),
                      hint: const Text(
                        'Select Employee*',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      items: employeProvider.employees.map((e) {
                        final initials = e.employeeName.isNotEmpty
                            ? e.employeeName
                                .trim()
                                .split(' ')
                                .map((w) => w[0])
                                .take(2)
                                .join()
                            : '?';
                        return DropdownMenuItem<Employee>(
                          value: e,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.indigo.shade100,
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.employeeName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Expanded(
                                      child: Text(
                                        e.employeeEmailId,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    const Divider()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedEmployee = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Last Date of Work*'),
              const SizedBox(height: 16),
              TextField(
                controller: datePickerController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: "Select Date*",
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                  helperText: pickedDate != null
                      ? 'Remaining Days - $remaingDays'
                      : null,
                  helperStyle: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationLinkController,
                decoration: const InputDecoration(
                  labelText: 'Location Link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButtonWithFullWidth(
                onPressed: () => _submitTask(employeProvider),
                buttonTitle:
                    widget.editTask == null ? 'Assign Task' : 'Update Task',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitTask(EmployeProvider employeProvider) async {
    if (selectedEmployee != null &&
        pickedDate != null &&
        descriptionController.text.trim().isNotEmpty) {
      bool taskAddedStatus = false;
      FocusManager.instance.primaryFocus?.unfocus();

      // Calling the API to assign task
      LoaderDialog.show(context: context);

      /// late task will be parse
      final task = Task(
        employeeName: selectedEmployee!.employeeName,
        description: descriptionController.text,
        taskComplitionDate: pickedDate.toString(),
        locationLink: locationLinkController.text,
        employeeMobileNumber: selectedEmployee!.employeeMobileNumber,
        employeeEmailId: selectedEmployee!.employeeEmailId,
      );

      final uid = await OneSignalUidManager()
          .getUid(employeeEmailId: selectedEmployee!.employeeEmailId);

      /// create a SelectedTaskDetailWithUrl object
      final selectedTask = SelectedTaskDetailWithUrl(
        task: task,
        imageUrl: 'assets/login/rod_stock.jpg',
        isCompletedButtonVisible: false,
      );

      // Schedule a notification for the due date with a fixed time of 10:00 AM
      DateTime formattedDate =
          DateTime(pickedDate!.year, pickedDate!.month, pickedDate!.day, 10, 0);
      final isBefore = formattedDate.isBefore(DateTime.now());
      if (isBefore) {
        formattedDate = formattedDate.add(const Duration(days: 1));
      }

      final notificationId =
          await OneSignalNotificationService().scheduleDueDateNotification(
        uid: uid ?? '',
        title: "⚠️ Task Overdue Today! ⚠️",
        body:
            'Your task is overdue Today. Please complete it as soon as possible',
        taskIdDetails: selectedTask.toJson(),
        scheduledTime: formattedDate,
      );

      /// Send notification to the user now
      await OneSignalNotificationService().sendNotificationToUser(
        uid: uid ?? '',
        title: '📝 New Task Assigned! 📝',
        body:
            'A new task has been assigned to you. Please review and start working on it',
        taskIdDetails: selectedTask.toJson(),
      );
      if (widget.editTask == null) {
        /// To Add New Task
        taskAddedStatus = await employeProvider.addTask(
          employeeName: selectedEmployee!.employeeName,
          description: descriptionController.text,
          taskComplitionDate: pickedDate.toString(),
          locationLink: locationLinkController.text,
          employeeMobileNumber: selectedEmployee!.employeeMobileNumber,
          employeeEmailId: selectedEmployee!.employeeEmailId,
          notificationId: notificationId ?? '',
        );
      } else {
        /// To Update Task
        taskAddedStatus = await employeProvider.updateTask(
          taskId: widget.editTask!.id ?? '',
          employeeName: selectedEmployee!.employeeName,
          description: descriptionController.text,
          taskComplitionDate: pickedDate.toString(),
          locationLink: locationLinkController.text,
          employeeMobileNumber: selectedEmployee!.employeeMobileNumber,
          employeeEmailId: selectedEmployee!.employeeEmailId,
          notificationId: notificationId ?? '',
        );
        OneSignalNotificationService()
            .cancelScheduledNotification(widget.editTask!.notificationId ?? '');
      }
      // If task was not added successfully, return early
      if (!taskAddedStatus) return;

      // Clear the input fields
      descriptionController.clear();
      locationLinkController.clear();
      datePickerController.clear();
      setState(() {
        selectedEmployee = null;
        pickedDate = null;
      });

      showTopSnackBar(
        context: context,
        message: taskAddedStatus
            ? widget.editTask == null
                ? 'Task Assigned Successfully!'
                : 'Task Updated Successfully!'
            : 'Failed to assign task!',
        bgColor: taskAddedStatus ? Colors.green : Colors.red,
      );
      if (widget.editTask != null && taskAddedStatus) {
        context.pop();
      }
      LoaderDialog.hide(context: context);
    } else {
      showTopSnackBar(context: context, message: 'Please fill all fields!!');
    }
  }
}
