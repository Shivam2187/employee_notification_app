import 'package:intl/intl.dart';

extension DateFormatting on DateTime {
  /// Format date to 'dd MMM yyyy' (e.g., 11 May 2025)
  String toddMMMyyyy() => DateFormat('dd MMM yyyy').format(this);

  /// Format date to 'yyyy-MM-dd' (e.g., 2025-05-11)
  String toyyyyMMdd() => DateFormat('yyyy-MM-dd').format(this);

  /// Format date to 'dd/MM/yyyy'
  String toSlashFormat() => DateFormat('dd/MM/yyyy').format(this);
}

extension DateStringFormat on String {
  /// Parses a string (ISO or common formats) and returns 'dd MMM yyyy'
  String toReadableDate() {
    try {
      final parsedDate = DateTime.parse(this);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return this; // fallback if parsing fails
    }
  }

  /// Parses and returns 'dd/MM/yyyy'
  String toSlashDate() {
    try {
      final parsedDate = DateTime.parse(this);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return this;
    }
  }

  /// Parses and returns a custom format
  String toFormattedDate(String pattern) {
    try {
      final parsedDate = DateTime.parse(this);
      return DateFormat(pattern).format(parsedDate);
    } catch (e) {
      return this;
    }
  }
}

extension StringExtension on String {
  /// Checks if the string is a valid email format
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Checks if the string is a valid phone number format
  bool isValidPhoneNumber() {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(this);
  }

  String getInitials() {
    final names = trim().split(" ");
    if (names.length >= 2) {
      return "${names[0][0]}${names[1][0]}".toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return "";
  }
}

extension StringUtilsForNullable on String? {
  /// checks if the string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// checks if the string is not null or empty
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}
