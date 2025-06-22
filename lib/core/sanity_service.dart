// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:notification_flutter_app/features/task_and_notification/data/models/employee.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/secret_key.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/task.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/global_store.dart';

class SanityService {
  String projectId = 'tqenxrzt';
  String dataset = 'production';
  String apiVersion = "v2025-05-10";
  final GlobalStroe globalStore = GlobalStroe();

  // Fetch Secret Key (GET request)
  Future<List<SecretKey>> fetchSecretKey() async {
    const query = '*[_type == "secretKeys"]{ _id, key, value}';
    final encodedQuery = Uri.encodeComponent(query);
    final url =
        'https://$projectId.api.sanity.io/$apiVersion/data/query/$dataset?query=$encodedQuery';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['result'];
      print(data);
      final secretKey = data.map((json) {
        return SecretKey.fromJson(json);
      }).toList();
      return secretKey;
    } else {
      throw Exception('Failed to fetch posts');
    }
  }

  // Add Employee (POST request)
  Future<bool> addEmployee({
    required String employeeName,
    required String employeeEmailId,
    String? description,
    String? address,
    String? emailId,
    String? employeeMobileNumber,
  }) async {
    final url =
        'https://$projectId.api.sanity.io/$apiVersion/data/mutate/$dataset';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${globalStore.getSecretValue(key: 'apiKey')}',
    };

    final body = jsonEncode({
      'mutations': [
        {
          'create': {
            '_type': 'employeeEvent',
            'employeeName': employeeName,
            'employeeMobileNumber': employeeMobileNumber,
            'address': address,
            'emailId': emailId,
            'description': description,
            'employeeEmailId': employeeEmailId,
          }
        }
      ]
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to Add Employee');
    }
  }

  // Fetch data (GET request)
  Future<List<Employee>> fetchEmployee() async {
    const query =
        '*[_type == "employeeEvent"]{ _id, employeeName, description, employeeMobileNumber, address, employeeEmailId}';
    final encodedQuery = Uri.encodeComponent(query);
    final url =
        'https://$projectId.api.sanity.io/$apiVersion/data/query/$dataset?query=$encodedQuery';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['result'];
      print(data);
      final employees = data.map((json) {
        return Employee.fromJson(json);
      }).toList();

      return employees;
    } else {
      throw Exception('Failed to fetch Employe List');
    }
  }

  //Delete Task (DELETE request)
  Future<bool> deleteEmployee({
    required String employeeId,
  }) async {
    final url =
        'https://$projectId.api.sanity.io/$apiVersion/data/mutate/$dataset';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${globalStore.getSecretValue(key: 'apiKey')}',
    };

    final body = jsonEncode({
      'mutations': [
        {
          'delete': {
            'id': employeeId,
          }
        }
      ]
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete Employee');
    }
  }

  // Add Task (POST request)
  Future<bool> addTask({
    required String employeeName,
    required String taskComplitionDate,
    required String description,
    required String emailId,
    required String mobileNumber,
    String? locationLink,
  }) async {
    final url =
        'https://$projectId.api.sanity.io/$apiVersion/data/mutate/$dataset';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${globalStore.getSecretValue(key: 'apiKey')}',
    };

    final body = jsonEncode({
      'mutations': [
        {
          'create': {
            '_type': 'taskEvent',
            'employeeName': employeeName,
            'taskComplitionDate': taskComplitionDate,
            'description': description,
            'emailId': emailId,
            'mobileNumber': mobileNumber,
            'locationLink': locationLink,
          }
        }
      ]
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to create post');
    }
  }

  // Fetch All Task (GET request)
  Future<List<Task>> fetchAllTask() async {
    const query =
        '*[_type == "taskEvent"]{ _id, employeeName, taskComplitionDate,description,emailId,locationLink, mobileNumber,isTaskCompleted }';
    final encodedQuery = Uri.encodeComponent(query);
    final url =
        'https://$projectId.api.sanity.io/$apiVersion/data/query/$dataset?query=$encodedQuery';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['result'];
      print(data);
      final taskList = data.map((json) {
        return Task.fromJson(json);
      }).toList();
      return taskList;
    } else {
      throw Exception('Failed to fetch posts');
    }
  }

  //Delete Task (DELETE request)
  Future<bool> deleteTask({
    required String taskId,
  }) async {
    final url =
        'https://$projectId.api.sanity.io/$apiVersion/data/mutate/$dataset';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${globalStore.getSecretValue(key: 'apiKey')}',
    };

    final body = jsonEncode({
      'mutations': [
        {
          'delete': {
            'id': taskId,
          }
        }
      ]
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete task');
    }
  }

  // Update Task (PATCH request)
  Future<bool> updateTaskStatus({
    required String taskId,
    required bool taskStatus,
  }) async {
    final url =
        'https://$projectId.api.sanity.io/$apiVersion/data/mutate/$dataset';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${globalStore.getSecretValue(key: 'apiKey')}',
    };

    final body = jsonEncode({
      'mutations': [
        {
          'patch': {
            'id': taskId,
            'set': {
              'isTaskCompleted': taskStatus,
            }
          }
        }
      ]
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to Update Task Status');
    }
  }
}
