// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:json_annotation/json_annotation.dart';

class Task {
  final String employeeName;
  final String taskComplitionDate;
  final String description;
  final String employeeEmailId;
  final String? locationLink;
  final String? employeeMobileNumber;

  @JsonKey(name: '_id')
  final String? id;

  final bool isTaskCompleted;

  Task({
    required this.employeeName,
    required this.taskComplitionDate,
    required this.employeeEmailId,
    required this.description,
    this.employeeMobileNumber,
    this.locationLink,
    this.id,
    this.isTaskCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] as String?,
      employeeName: json['employeeName'] as String,
      taskComplitionDate: json['taskComplitionDate'] as String,
      description: json['description'] as String,
      employeeEmailId: json['employeeEmailId'] as String,
      employeeMobileNumber: json['employeeMobileNumber'] as String?,
      locationLink: json['locationLink'] as String?,
      isTaskCompleted: json['isTaskCompleted'] as bool? ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'employeeName': employeeName,
      'taskComplitionDate': taskComplitionDate,
      'description': description,
      'employeeEmailId': employeeEmailId,
      'locationLink': locationLink,
      'employeeMobileNumber': employeeMobileNumber,
      'isTaskCompleted': isTaskCompleted,
    };
  }

  /// from map

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['_id'] as String?,
      employeeName: map['employeeName'] as String,
      taskComplitionDate: map['taskComplitionDate'] as String,
      description: map['description'] as String,
      employeeEmailId: map['employeeEmailId'] as String,
      employeeMobileNumber: map['employeeMobileNumber'] as String?,
      locationLink: map['locationLink'] as String?,
      isTaskCompleted: map['isTaskCompleted'] as bool? ?? false,
    );
  }
}
