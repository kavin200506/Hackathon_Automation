import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/validators.dart';
import '../../../services/auth_api.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_input.dart';
import '../../../widgets/common/auth_step_indicator.dart';

class CollegeRegisterScreen extends StatefulWidget {
  const CollegeRegisterScreen({super.key});

  @override
  State<CollegeRegisterScreen> createState() => _CollegeRegisterScreenState();
}

class _CollegeRegisterScreenState extends State<CollegeRegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _tpoNameController = TextEditingController();
  final TextEditingController _tpoContactController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _tpoNameController.dispose();
    _tpoContactController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      await AuthAPI.collegeRegister({
        'name': _nameController.text.trim(),
        'email': email,
        'contact_number': _contactController.text.trim(),
        'address': _addressController.text.trim(),
        'tpo_name': _tpoNameController.text.trim(),
        'tpo_contact_number': _tpoContactController.text.trim(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('college_email', email);

      if (!mounted) return;
      ErrorHandler.showSuccess('OTP sent to your email!');
      context.go(AppConstants.routeCollegeVerifyOtp);
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.success50,
              Colors.white,
              AppTheme.success100,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          context.go(AppConstants.routeCollegeLogin),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: AppTheme.gray600,
                      ),
                      label: const Text(
                        'Back to Login',
                        style: TextStyle(
                          color: AppTheme.gray600,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const AuthStepIndicator(currentStep: 1),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Center(
                              child: Text(
                                'College Registration',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.gray900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Center(
                              child: Text(
                                'Register your institution on the platform',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.gray500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            AppInput(
                              label: 'College Name',
                              hintText: 'Enter college name',
                              controller: _nameController,
                              validator: (value) =>
                                  Validators.validateRequired(value, fieldName: 'College name'),
                            ),
                            const SizedBox(height: 14),
                            AppInput(
                              label: 'Official Email',
                              hintText: 'Enter official email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 14),
                            AppInput(
                              label: 'Contact Number',
                              hintText: 'College contact number',
                              controller: _contactController,
                              keyboardType: TextInputType.phone,
                              validator: Validators.validateMobile,
                            ),
                            const SizedBox(height: 14),
                            AppInput(
                              label: 'Address',
                              hintText: 'Full postal address',
                              controller: _addressController,
                              maxLines: 3,
                              validator: (value) =>
                                  Validators.validateRequired(value, fieldName: 'Address'),
                            ),
                            const SizedBox(height: 14),
                            AppInput(
                              label: 'TPO Name',
                              hintText: 'Training & Placement Officer name',
                              controller: _tpoNameController,
                              validator: (value) =>
                                  Validators.validateRequired(value, fieldName: 'TPO name'),
                            ),
                            const SizedBox(height: 14),
                            AppInput(
                              label: 'TPO Contact Number',
                              hintText: 'TPO contact number',
                              controller: _tpoContactController,
                              keyboardType: TextInputType.phone,
                              validator: Validators.validateMobile,
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              isFullWidth: true,
                              isLoading: _isLoading,
                              onPressed: _handleRegister,
                              child: const Text(
                                'Register & Send OTP',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.gray600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      context.go(AppConstants.routeCollegeLogin),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.success600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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












