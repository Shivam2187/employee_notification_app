import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/add_employee_bottomsheet.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/employee_details_dialog.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/loader.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/custom_search.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/top_snake_bar.dart';
import 'package:notification_flutter_app/utils/extention.dart';
import 'package:provider/provider.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/employee_provider.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/appbar.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/employee_add_form.dart';

class AdminEmployeeDashboard extends StatefulWidget {
  const AdminEmployeeDashboard({
    super.key,
  });

  @override
  State<AdminEmployeeDashboard> createState() => _AdminEmployeeDashboardState();
}

class _AdminEmployeeDashboardState extends State<AdminEmployeeDashboard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeProvider>(
      builder: (context, data, child) {
        final filteredEmployeeList = data.getFilteredEmployee;

        return Scaffold(
          appBar: const FancyAppBar(title: 'Employee Details'),
          body: data.employees.isEmpty
              ? Lottie.asset(
                  'assets/animations/loading.json',
                  width: double.infinity,
                  height: double.infinity,
                  repeat: true,
                )
              : Column(
                  children: [
                    CustomSearchBar(
                      hinText: 'Find employee by name',
                      onChanged: (value) {
                        data.setEmployeeSearchQuery(value);
                      },
                      initialText: data.getEmployeeSearchQuery,
                    ),
                    if (filteredEmployeeList.isNotEmpty)
                      Expanded(
                        child: AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 32),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: filteredEmployeeList.length,
                            itemBuilder: (ctx, index) {
                              final employeeDetails =
                                  filteredEmployeeList[index];
                              final initialText =
                                  employeeDetails.employeeName.getInitials();
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                child: SlideAnimation(
                                  horizontalOffset: 200,
                                  duration: const Duration(milliseconds: 800),
                                  child: FadeInAnimation(
                                    duration: const Duration(milliseconds: 800),
                                    child: Card(
                                      margin: const EdgeInsets.all(8),
                                      child: ListTile(
                                        title: Text(
                                          employeeDetails.employeeName,
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              employeeDetails.employeeEmailId,
                                            ),
                                            if (employeeDetails
                                                .employeeMobileNumber
                                                .isNotNullOrEmpty)
                                              Text(
                                                employeeDetails
                                                    .employeeMobileNumber!,
                                              ),
                                          ],
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.blue,
                                          child: initialText.isEmpty
                                              ? const Icon(Icons.person)
                                              : Text(
                                                  employeeDetails.employeeName
                                                      .getInitials(),
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                        ),
                                        onTap: () => employeeDetailsDialog(
                                          employeeDetails,
                                          context,
                                        ),
                                        trailing: IconButton(
                                          icon: Lottie.asset(
                                              'assets/animations/delete.json',
                                              repeat: true,
                                              width: 50,
                                              height: 50),
                                          onPressed: () async {
                                            if (employeeDetails.id == null) {
                                              return;
                                            }

                                            // Calling Delete Task API
                                            LoaderDialog.show(context: context);
                                            final status =
                                                await data.deleteEmployee(
                                              employeeId: employeeDetails.id!,
                                            );
                                            LoaderDialog.hide(context: context);
                                            showTopSnackBar(
                                              context: context,
                                              message: status
                                                  ? 'Succesfully deleted'
                                                  : 'Failed to delete',
                                              bgColor: status
                                                  ? Colors.green
                                                  : Colors.red,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    if (filteredEmployeeList.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            'No Employee Found with the name ${data.getEmployeeSearchQuery}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              final formKey = GlobalKey<EmployeeAddFormState>();

              showAddEmployeeBottomSheet(
                context: context,
                contentWidget: EmployeeAddForm(
                  key: formKey,
                ),
                stickyWidget: ElevatedButton(
                  onPressed: () async {
                    await formKey.currentState?.handleSubmit();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 16,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
            label: const Text('Add Employee'),
            icon: Lottie.asset(
              'assets/animations/add_employee.json',
              repeat: true,
              width: 32,
            ),
          ),
        );
      },
    );
  }
}
