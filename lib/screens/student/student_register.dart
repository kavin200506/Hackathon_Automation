import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/validators.dart';
import '../../../services/auth_api.dart';
import '../../../services/college_api.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_input.dart';
import '../../../widgets/common/auth_step_indicator.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _registerNumberController =
      TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _passedOutYearController =
      TextEditingController();

  bool _isLoading = false;
  bool _isLoadingColleges = false;
  List<Map<String, dynamic>> _colleges = [];
  String? _selectedCollegeId;

  @override
  void initState() {
    super.initState();
    _loadColleges();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _registerNumberController.dispose();
    _degreeController.dispose();
    _departmentController.dispose();
    _passedOutYearController.dispose();
    super.dispose();
  }

  Future<void> _loadColleges() async {
    setState(() {
      _isLoadingColleges = true;
    });

    try {
      final result = await CollegeAPI.getCollegesList();
      setState(() {
        _colleges = result.cast<Map<String, dynamic>>();
      });
    } catch (error) {
      setState(() {
        _colleges = [
          {'id': '1', 'name': 'Sample College A'},
          {'id': '2', 'name': 'Sample College B'},
        ];
      });
    } finally {
      setState(() {
        _isLoadingColleges = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCollegeId == null) {
      ErrorHandler.showError('Please select your college');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();

      await AuthAPI.studentRegister({
        'name': _nameController.text.trim(),
        'email': email,
        'mobile': _mobileController.text.trim(),
        'college_id': _selectedCollegeId,
        'register_number': _registerNumberController.text.trim(),
        'degree': _degreeController.text.trim(),
        'department': _departmentController.text.trim(),
        'passed_out_year': _passedOutYearController.text.trim(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('student_email', email);

      if (!mounted) return;
      ErrorHandler.showSuccess('OTP sent to your email!');
      context.go(AppConstants.routeStudentVerifyOtp);
    } catch (error) {
      ErrorHandler.handleAPIError(error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
              AppTheme.primary50,
              Colors.white,
              AppTheme.secondary50,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          context.go(AppConstants.routeStudentLogin),
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
                          children: [
                            const Center(
                              child: Text(
                                'Create Account',
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
                                'Fill in your details to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.gray500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            AppInput(
                              label: 'Full Name',
                              hintText: 'Enter your full name',
                              controller: _nameController,
                              validator: Validators.validateName,
                            ),
                            const SizedBox(height: 14),
                            AppInput(
                              label: 'Email Address',
                              hintText: 'Enter your email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 14),
                            AppInput(
                              label: 'Mobile Number',
                              hintText: 'Enter your mobile number',
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              validator: Validators.validateMobile,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'College',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.gray700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedCollegeId,
                              decoration: InputDecoration(
                                hintText: _isLoadingColleges
                                    ? 'Loading colleges...'
                                    : 'Select your college',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.gray300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.gray300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.primary500,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppTheme.error500,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              items: _colleges
                                  .map(
                                    (c) => DropdownMenuItem<String>(
                                      value: c['id']?.toString(),
                                      child: Text(c['name']?.toString() ?? ''),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCollegeId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select your college';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            AppInput(
                              label: 'Register Number',
                              hintText: 'Enter your register number',
                              controller: _registerNumberController,
                              validator: (value) => Validators.validateRequired(
                                value,
                                fieldName: 'Register number',
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppInput(
                              label: 'Degree',
                              hintText: 'e.g., B.Tech, B.E, MCA',
                              controller: _degreeController,
                              validator: (value) => Validators.validateRequired(
                                value,
                                fieldName: 'Degree',
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppInput(
                              label: 'Department',
                              hintText: 'e.g., Computer Science',
                              controller: _departmentController,
                              validator: (value) => Validators.validateRequired(
                                value,
                                fieldName: 'Department',
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppInput(
                              label: 'Passing Year',
                              hintText: 'e.g., 2026',
                              controller: _passedOutYearController,
                              keyboardType: TextInputType.number,
                              validator: Validators.validateYear,
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              isFullWidth: true,
                              isLoading: _isLoading,
                              onPressed: _handleRegister,
                              child: const Text(
                                'Send OTP & Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
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
                                  onTap: () => context
                                      .go(AppConstants.routeStudentLogin),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primary600,
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

