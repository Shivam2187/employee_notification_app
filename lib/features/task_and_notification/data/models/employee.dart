import 'package:json_annotation/json_annotation.dart';

class Employee {
  final String employeeName;
  final String employeeEmailId;
  final String employeeMobileNumber;
  @JsonKey(name: '_id')
  final String? id;
  final String? description;
  final String? address;

  Employee({
    this.id,
    required this.employeeName,
    required this.employeeEmailId,
    required this.employeeMobileNumber,
    this.address,
    this.description,
  });
  @override
  bool operator ==(Object other) {
    return other is Employee && other.employeeEmailId == employeeEmailId;
  }

  @override
  int get hashCode => employeeEmailId.hashCode;
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'] as String?,
      employeeName: json['employeeName'] as String,
      employeeEmailId: json['employeeEmailId'] as String,
      employeeMobileNumber: json['employeeMobileNumber'] as String,
      address: json['address'] as String?,
      description: json['description'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'employeeName': employeeName,
      'employeeEmailId': employeeEmailId,
      'employeeMobileNumber': employeeMobileNumber,
      'address': address,
      'description': description,
    };
  }
}
