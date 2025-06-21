import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/screens/admin_task_allocation_dashboard.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/screens/admin_employee_dashboard.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/screens/admin_task_dashboard.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({
    super.key,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final widgetOptions = <Widget>[
      const AdminEmployeeDashboard(),
      const AdminTaskDashboard(),
      const AdminTaskAllocationDashboard(),
    ];
    return Scaffold(
      body: widgetOptions[currentIndex],
      bottomNavigationBar: Material(
        elevation: 32,
        child: CurvedNavigationBar(
          animationDuration: const Duration(milliseconds: 600),
          color: Colors.white,
          buttonBackgroundColor: Colors.grey,
          index: currentIndex,
          items: const [
            CurvedNavigationBarItem(
              child: Icon(Icons.people),
              label: 'All Employee',
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.task),
              label: 'All Task',
            ),
            CurvedNavigationBarItem(
              child: Icon(Icons.add_task),
              label: 'Add Task',
            ),
          ],
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
