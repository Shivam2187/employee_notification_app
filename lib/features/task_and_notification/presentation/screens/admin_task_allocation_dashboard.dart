import 'package:flutter/material.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/employee.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/task.dart';
import 'package:notification_flutter_app/firebase/fmc_token_manager.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/loader.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/top_snake_bar.dart';
import 'package:provider/provider.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/employee_provider.dart';

import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/appbar.dart';

class AdminTaskAllocationDashboard extends StatefulWidget {
  const AdminTaskAllocationDashboard({
    super.key,
  });

  @override
  State<AdminTaskAllocationDashboard> createState() =>
      _AdminTaskAllocationDashboardState();
}

class _AdminTaskAllocationDashboardState
    extends State<AdminTaskAllocationDashboard> {
  final List<int> daysOptions = List.generate(100, (index) => index + 1);
  Employee? selectedEmployee;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationLinkController = TextEditingController();
  final TextEditingController _controller = TextEditingController();

  DateTime? pickedDate;

  @override
  void initState() {
    super.initState();
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
        _controller.text =
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
              DropdownButton<Employee>(
                value: selectedEmployee,
                isExpanded: true,
                hint: const Text('Choose Employee*'),
                items: employeProvider.employees
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child:
                              Text('${e.employeeName} - ${e.employeeEmailId}'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEmployee = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Last Date of Work*'),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
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
              Center(
                  child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _submitTask(employeProvider),
                  style: ElevatedButton.styleFrom(
                    elevation: 16,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Assign Task',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _submitTask(EmployeProvider employeProvider) async {
    if (selectedEmployee != null &&
        pickedDate != null &&
        descriptionController.text.isNotEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();

      // Calling the API to assign task
      LoaderDialog.show(context: context);
      final status = await employeProvider.addTask(
        employeeName: selectedEmployee?.employeeName ?? '',
        description: descriptionController.text,
        taskComplitionDate: pickedDate.toString(),
        locationLink: locationLinkController.text,
        mobileNiumber: selectedEmployee?.employeeMobileNumber ?? '',
        emailId: selectedEmployee?.employeeEmailId ?? '',
      );
      LoaderDialog.hide(context: context);

      if (status) {
        // Clear the input fields

        final task = Task(
          employeeName: selectedEmployee?.employeeName ?? '',
          description: descriptionController.text,
          taskComplitionDate: pickedDate.toString(),
          locationLink: locationLinkController.text,
          mobileNumber: selectedEmployee?.employeeMobileNumber ?? '',
          employeeEmailId: selectedEmployee?.employeeEmailId ?? '',
        );

        await FCMTokenManager().sendTaskNotification(task: task);

        descriptionController.clear();
        locationLinkController.clear();
        _controller.clear();
        setState(() {
          selectedEmployee = null;
          pickedDate = null;
        });
      }

      showTopSnackBar(
        context: context,
        message:
            status ? 'Task Assigned Successfully!' : 'Failed to assign task!',
        bgColor: status ? Colors.green : Colors.red,
      );
    } else {
      showTopSnackBar(context: context, message: 'Please fill all fields!!');
    }
  }
}
