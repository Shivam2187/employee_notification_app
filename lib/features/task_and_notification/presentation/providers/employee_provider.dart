// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:notification_flutter_app/core/debug_print.dart';
import 'package:notification_flutter_app/core/locator.dart';
import 'package:notification_flutter_app/core/sanity_service.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/employee.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/task.dart';
import 'package:notification_flutter_app/firebase/one_signal_notification.dart';
import 'package:notification_flutter_app/utils/extention.dart';

class EmployeProvider extends ChangeNotifier {
  List<Employee> _employees = [];
  List<Employee> get employees => _employees;
  List<Employee> notifications = [];
  List<Task> _taskList = [];
  List<Task> get taskList => _taskList;

  String _taskSearchQuery = '';
  String get getTaskSearchQuery => _taskSearchQuery;
  String _employeeSearchQuery = '';
  String get getEmployeeSearchQuery => _employeeSearchQuery;

// This is the search query used to filter the task list
  List<Task> get getFilteredTask => _taskSearchQuery.isEmpty
      ? getNonArchivedTask
      : getNonArchivedTask.where(
          (task) {
            return task.employeeName
                .toLowerCase()
                .contains(_taskSearchQuery.toLowerCase());
          },
        ).toList();

  /// get filtered task which is not archived
  List<Task> get getNonArchivedTask =>
      _taskList.where((task) => !task.isTaskArchived).toList();

  /// get   archived Task
  List<Task> get getArchivedTask {
    return _taskList.where((task) => task.isTaskArchived).toList();
  }

  void setTaskSearchQuery(String query) {
    _taskSearchQuery = query.trim();
    notifyListeners();
  }

// This is the search query used to filter the employee list
  List<Employee> get getFilteredEmployee => _employees.isEmpty
      ? _employees
      : _employees.where(
          (e) {
            return e.employeeName
                .toLowerCase()
                .contains(_employeeSearchQuery.toLowerCase());
          },
        ).toList();

  void setEmployeeSearchQuery(String query) {
    _employeeSearchQuery = query.trim();
    notifyListeners();
  }

// Create data (POST request)
  Future<bool> addEmployee({
    required String employeeName,
    required String employeeEmailId,
    String? employeeMobileNumber,
    String? emailId,
    String? description,
    String? address,
  }) async {
    try {
      final status = await locator.get<SanityService>().addEmployee(
            employeeName: employeeName,
            employeeEmailId: employeeEmailId,
            employeeMobileNumber: employeeMobileNumber,
            description: description,
            address: address,
          );
      // Optionally, you can fetch the updated list of employees after adding a new one
      if (status) {
        fetchEmployee();
      }
      return status;
    } catch (e) {
      debugprint('Error creating post: $e');
      return false;
    }
  }

  // Fetch Employee List (GET request)
  Future<void> fetchEmployee() async {
    try {
      _employees = await locator.get<SanityService>().fetchEmployee();
      notifyListeners();
    } catch (e) {
      debugprint('Error fetching employees: $e');
    }
  }

  // Delete Employee (DELETE request)
  Future<bool> deleteEmployee({
    required String employeeId,
  }) async {
    try {
      final status = await locator.get<SanityService>().deleteEmployee(
            employeeId: employeeId,
          );
      if (status) {
        fetchEmployee();
      }

      return status;
    } catch (e) {
      debugprint('Error Deleting post: $e');
      return false;
    }
  }

  // Create data (POST request)
  Future<bool> addTask({
    required String employeeName,
    required String taskComplitionDate,
    required String employeeEmailId,
    required String description,
    required String employeeMobileNumber,
    String? locationLink,
    required String notificationId,
  }) async {
    try {
      final status = await locator.get<SanityService>().addTask(
          employeeName: employeeName,
          taskComplitionDate: taskComplitionDate,
          employeeEmailId: employeeEmailId,
          description: description,
          employeeMobileNumber: employeeMobileNumber,
          locationLink: locationLink,
          notificationId: notificationId);
      if (status) {
        fetchAllTask();
      }

      return status;
    } catch (e) {
      debugprint('Error creating post: $e');
      return false;
    }
  }

  // Fetch All Task (GET request)
  Future<List<Task>> fetchAllTask() async {
    try {
      _taskList = await locator.get<SanityService>().fetchAllTask();
      notifyListeners();
      return _taskList;
    } catch (e) {
      debugprint('Error fetching employees: $e');
      return [];
    }
  }

  // Create data (POST request)
  Future<bool> deleteTask({
    required String taskId,
  }) async {
    try {
      final status = await locator.get<SanityService>().deleteTask(
            taskId: taskId,
          );
      if (status) {
        fetchAllTask();
      }

      return status;
    } catch (e) {
      debugprint('Error- Failed to Deleate task: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteAllArchievedTask({
    required List<Task> taskList,
  }) async {
    final validTasks = taskList
        .where((task) => task.id != null && task.id!.isNotEmpty)
        .toList();
    final validNotificationId = taskList
        .where((task) =>
            task.notificationId != null &&
            task.notificationId!.isNotNullOrEmpty)
        .toList();

    if (validTasks.isEmpty) {
      debugprint('No valid tasks to delete.');
      return true;
    }

    final results = await Future.wait(
      validTasks.map((task) => deleteTask(taskId: task.id!)),
    );

    /// Delete scheduled notification
    Future.wait(
      validNotificationId.map((task) => OneSignalNotificationService()
          .cancelScheduledNotification(task.notificationId)),
    );

    final allSuccess = results.every((status) => status == true);
    fetchAllTask();
    if (allSuccess) {
      debugprint('${validTasks.length} tasks deleted successfully!');
      return true;
    } else {
      debugprint('Some tasks failed to delete!');
      return false;
    }
  }

  List<Task> getFilteredAndSortedTask({
    required String employeeEmailId,
  }) {
    final filteredTasks = taskList
        .where((task) =>
            task.employeeEmailId == employeeEmailId && !task.isTaskArchived)
        .toList();
    filteredTasks.sort((a, b) {
      // Put incomplete tasks first
      if (a.isTaskCompleted && !b.isTaskCompleted) return 1;
      if (!a.isTaskCompleted && b.isTaskCompleted) return -1;
      return a.taskComplitionDate.compareTo(b.taskComplitionDate);
    });
    return filteredTasks;
  }

  // Create data (POST request)
  Future<bool> updateTaskStatus({
    required String taskId,
  }) async {
    try {
      final status = await locator.get<SanityService>().updateTaskStatus(
            taskStatus: true,
            taskId: taskId,
          );
      if (status) {
        fetchAllTask();
      }

      return status;
    } catch (e) {
      debugprint('Error while Updating Task Status: $e');
      return false;
    }
  }

  // Create data (POST request)
  Future<bool> updateArchieveStatus({
    required String taskId,
  }) async {
    try {
      final status = await locator.get<SanityService>().updateArchievedStatus(
            taskArchievedStatus: true,
            taskId: taskId,
          );
      if (status) {
        fetchAllTask();
      }

      return status;
    } catch (e) {
      debugprint('Error while Updating Task Status: $e');
      return false;
    }
  }
}
