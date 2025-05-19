import 'package:json_annotation/json_annotation.dart';

class Employee {
  final String employeeName;
  final String employeeMobileNumber;
  final String? emailId;

  @JsonKey(name: '_id')
  final String? id;

  final String? description;
  final String? address;

  Employee({
    this.id,
    required this.employeeName,
    required this.employeeMobileNumber,
    this.emailId,
    this.address,
    this.description,
  });
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'] as String?,
      employeeName: json['employeeName'] as String,
      emailId: json['emailId'] as String?,
      employeeMobileNumber: json['employeeMobileNumber'] as String,
      address: json['address'] as String?,
      description: json['description'] as String?,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'employeeName': employeeName,
      'emailId': emailId,
      'employeeMobileNumber': employeeMobileNumber,
      'address': address,
      'description': description,
    };
  }
}
