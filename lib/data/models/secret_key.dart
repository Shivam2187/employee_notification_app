// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:json_annotation/json_annotation.dart';

class SecretKey {
  final String key;
  final String value;

  @JsonKey(name: '_id')
  final String? id;

  SecretKey({
    required this.key,
    required this.value,
    this.id,
  });

  factory SecretKey.fromJson(Map<String, dynamic> json) {
    return SecretKey(
      id: json['_id'] as String?,
      key: json['key'] as String,
      value: json['value'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'key': key,
      'value': value,
    };
  }
}
