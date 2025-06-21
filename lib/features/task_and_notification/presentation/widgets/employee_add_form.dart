import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/loader.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/widgets/top_snake_bar.dart';
import 'package:notification_flutter_app/features/task_and_notification/presentation/providers/employee_provider.dart';

class EmployeeAddForm extends StatefulWidget {
  const EmployeeAddForm({super.key});

  @override
  EmployeeAddFormState createState() => EmployeeAddFormState();
}

class EmployeeAddFormState extends State<EmployeeAddForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  Future<void> handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final employeeName = _nameController.text.trim();
      final employeeMobileNumber = _mobileController.text.trim();
      final description = _descriptionController.text.trim();
      final address = _addressController.text.trim();
      final emailId = _emailController.text.trim();

      if (!mounted) return;
      LoaderDialog.show(context: context);

      final status = await context.read<EmployeProvider>().addEmployee(
            employeeName: employeeName,
            employeeMobileNumber: employeeMobileNumber,
            emailId: emailId,
            description: description,
            address: address,
          );

      LoaderDialog.hide(context: context);

      if (status) context.pop();

      showTopSnackBar(
        context: context,
        message:
            status ? 'Employee added successfully' : 'Failed to add employee',
        bgColor: status ? Colors.green : Colors.red,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTextField(
            _nameController,
            'Employee Name*',
            prefixIcon: const Icon(Icons.person),
            validator: (value) =>
                value == null || value.isEmpty ? 'Name is required!' : null,
          ),
          _buildTextField(
            _mobileController,
            'Employee Mobile Number*',
            prefixIcon: const Icon(Icons.phone),
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mobile number required!';
              }
              if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                return 'Enter valid 10-digit number!';
              }
              return null;
            },
          ),
          _buildTextField(
            _emailController,
            'Email ID',
            prefixIcon: const Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
          ),
          _buildTextField(
            _addressController,
            'Address',
            maxLines: 2,
            prefixIcon: const Icon(Icons.home),
          ),
          _buildTextField(
            _descriptionController,
            'Description',
            maxLines: 3,
            prefixIcon: const Icon(Icons.description),
          ),
          const SizedBox(height: 16), // space for keyboard
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLength,
    Widget? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        textAlignVertical: TextAlignVertical.center,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          counterText: '',
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}
