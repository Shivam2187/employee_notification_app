// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:json_annotation/json_annotation.dart';

class Task {
  final String employeeName;
  final String taskComplitionDate;
  final String description;
  final String? locationLink;
  final String? emailId;
  final String mobileNumber;

  @JsonKey(name: '_id')
  final String? id;

  final bool isTaskCompleted;

  Task({
    required this.employeeName,
    required this.taskComplitionDate,
    required this.description,
    required this.mobileNumber,
    this.locationLink,
    this.emailId,
    this.id,
    this.isTaskCompleted = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'] as String?,
      employeeName: json['employeeName'] as String,
      taskComplitionDate: json['taskComplitionDate'] as String,
      description: json['description'] as String,
      emailId: json['emailId'] as String?,
      mobileNumber: json['mobileNumber'] as String,
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
      'emailId': emailId,
      'locationLink': locationLink,
      'mobileNumber': mobileNumber,
      'isTaskCompleted': isTaskCompleted,
    };
  }
}
