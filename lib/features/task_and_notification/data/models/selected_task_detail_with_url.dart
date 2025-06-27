import 'dart:convert';

import 'package:notification_flutter_app/features/task_and_notification/data/models/task.dart';

class SelectedTaskDetailWithUrl {
  final Task task;
  final String imageUrl;
  final bool isCompletedButtonVisible;

  SelectedTaskDetailWithUrl({
    required this.task,
    required this.imageUrl,
    this.isCompletedButtonVisible = false,
  });

  // To json method for serialization
  Map<String, dynamic> toJson() {
    return {
      'task': task.toJson(),
      'imageUrl': imageUrl,
      'isCompletedButtonVisible': isCompletedButtonVisible,
    };
  }

  // from map method for deserialization
  static SelectedTaskDetailWithUrl fromMap(Map<String, dynamic> map) {
    return SelectedTaskDetailWithUrl(
      task: Task.fromMap(map['task']),
      imageUrl: map['imageUrl'] as String,
      isCompletedButtonVisible:
          map['isCompletedButtonVisible'] as bool? ?? false,
    );
  }

  // From json method for deserialization
  factory SelectedTaskDetailWithUrl.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> task = Map<String, dynamic>.from(json['task']);
    return SelectedTaskDetailWithUrl(
      task: Task.fromJson(task),
      imageUrl: json['imageUrl'] as String,
      isCompletedButtonVisible:
          json['isCompletedButtonVisible'] as bool? ?? false,
    );
  }

  /// String to object
  static SelectedTaskDetailWithUrl fromString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return SelectedTaskDetailWithUrl.fromJson(json);
  }

  /// string to object

  @override
  String toString() =>
      'SelectedTaskDetailWithUrl(task: $task, imageUrl: $imageUrl, isCompletedButtonVisible: $isCompletedButtonVisible)';
}
