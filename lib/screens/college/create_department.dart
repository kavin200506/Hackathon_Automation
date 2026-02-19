import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/validators.dart';
import '../../../services/college_api.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_input.dart';

class CreateDepartmentScreen extends StatefulWidget {
  const CreateDepartmentScreen({super.key});

  @override
  State<CreateDepartmentScreen> createState() => _CreateDepartmentScreenState();
}

class _CreateDepartmentScreenState extends State<CreateDepartmentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hodNameController = TextEditingController();
  final TextEditingController _hodEmailController = TextEditingController();
  final TextEditingController _hodContactController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _hodNameController.dispose();
    _hodEmailController.dispose();
    _hodContactController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await CollegeAPI.createDepartment({
        'name': _nameController.text.trim(),
        'hod_name': _hodNameController.text.trim(),
        'hod_email': _hodEmailController.text.trim(),
        'hod_contact': _hodContactController.text.trim(),
      });

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Department Created!'),
            content: const Text(
              'Login credentials have been sent to HOD email.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;
      context.go(AppConstants.routeCollegeViewDepartments);
    } catch (error) {
      ErrorHandler.handleAPIError(error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Create Department'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeCollegeDashboard),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Department',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a new department and assign a HOD.',
                      style: TextStyle(fontSize: 14, color: AppTheme.gray600),
                    ),
                    const SizedBox(height: 24),
                    AppInput(
                      label: 'Department Name',
                      hintText: 'Enter department name',
                      controller: _nameController,
                      validator: (value) => Validators.validateRequired(
                        value,
                        fieldName: 'Department name',
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      label: 'HOD Name',
                      hintText: 'Head of Department name',
                      controller: _hodNameController,
                      validator: (value) => Validators.validateRequired(
                        value,
                        fieldName: 'HOD name',
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      label: 'HOD Email',
                      hintText: 'HOD email address',
                      controller: _hodEmailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      label: 'HOD Contact',
                      hintText: 'HOD mobile number',
                      controller: _hodContactController,
                      keyboardType: TextInputType.phone,
                      validator: Validators.validateMobile,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      isFullWidth: true,
                      isLoading: _isLoading,
                      onPressed: _handleSubmit,
                      child: const Text(
                        'Create Department',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
