import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notification_flutter_app/features/task_and_notification/data/models/employee.dart';

void employeeDetailsDialog(Employee employeeDetails, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(Icons.person, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              employeeDetails.employeeName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(Icons.phone, employeeDetails.employeeMobileNumber!),
          if (employeeDetails.employeeEmailId.isNotEmpty)
            _infoRow(Icons.email, employeeDetails.employeeEmailId),
          if (employeeDetails.description?.isNotEmpty ?? false)
            _infoRow(Icons.description, employeeDetails.description!),
          if ((employeeDetails.address?.isNotEmpty ?? false))
            if ((employeeDetails.address?.isNotEmpty ?? false))
              _infoRow(Icons.home, employeeDetails.address!),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close, color: Colors.white),
          label: const Text('Close', style: TextStyle(color: Colors.white)),
          style: TextButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _infoRow(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
