import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../models/college.dart';
import '../../../services/auth_api.dart';
import '../../../services/college_api.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_input.dart';
import '../../../widgets/common/app_loader.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _registerNumberController = TextEditingController();
  final _degreeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passedOutYearController = TextEditingController();

  List<College> _colleges = [];
  String? _selectedCollegeId = '';
  bool _isLoading = false;
  bool _isFetchingColleges = true;

  @override
  void initState() {
    super.initState();
    _fetchColleges();
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

  Future<void> _fetchColleges() async {
    try {
      final data = await CollegeAPI.getCollegesList();
      final colleges = data
          .map((c) => College.fromJson(c))
          .toList();
      
      if (mounted) {
        setState(() {
          _colleges = colleges;
          _isFetchingColleges = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isFetchingColleges = false);
        ErrorHandler.handleAPIError(error);
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value.trim())) {
      return 'Invalid email address';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
      return 'Mobile number must be 10 digits';
    }
    return null;
  }


  String? _validateRegisterNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Register number is required';
    }
    return null;
  }

  String? _validateDegree(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Degree is required';
    }
    return null;
  }

  String? _validateDepartment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Department is required';
    }
    return null;
  }

  String? _validatePassedOutYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Passed out year is required';
    }
    if (!RegExp(r'^\d{4}$').hasMatch(value.trim())) {
      return 'Invalid year (must be 4 digits)';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCollegeId == null || _selectedCollegeId!.isEmpty) {
      ErrorHandler.showError('Please select a college');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'college_id': _selectedCollegeId,
        'register_number': _registerNumberController.text.trim(),
        'degree': _degreeController.text.trim(),
        'department': _departmentController.text.trim(),
        'passed_out_year': _passedOutYearController.text.trim(),
      };

      await AuthAPI.studentRegister(data);

      // Store email for OTP verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('student_email', _emailController.text.trim());

      if (!mounted) return;
      ErrorHandler.showSuccess('Registration successful! Please verify OTP sent to your email.');
      
      if (mounted) {
        context.go(AppConstants.routeStudentVerifyOtp);
      }
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
    if (_isFetchingColleges) {
      return const AppLoader();
    }

    return Scaffold(
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
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: AppCard(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary500, AppTheme.secondary500],
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ShaderMask(
                          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                          child: const Text(
                            'Student Registration',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your account to participate in hackathons',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.gray600,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Form Fields
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 600;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                                  child: AppInput(
                                    label: 'Full Name',
                                    hintText: 'Enter your full name',
                                    controller: _nameController,
                                    isRequired: true,
                                    validator: _validateName,
                                  ),
                                ),
                                SizedBox(
                                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                                  child: AppInput(
                                    label: 'Email Address',
                                    hintText: 'Enter your email',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    isRequired: true,
                                    validator: _validateEmail,
                                  ),
                                ),
                                SizedBox(
                                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                                  child: AppInput(
                                    label: 'Mobile Number',
                                    hintText: '10-digit mobile number',
                                    controller: _mobileController,
                                    keyboardType: TextInputType.phone,
                                    isRequired: true,
                                    validator: _validateMobile,
                                  ),
                                ),
                                SizedBox(
                                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            const Text(
                                              'College',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.gray700,
                                              ),
                                            ),
                                            const Text(
                                              ' *',
                                              style: TextStyle(color: AppTheme.error500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DropdownButtonFormField<String>(
                                        value: _selectedCollegeId,
                                        decoration: InputDecoration(
                                          hintText: 'Select your college',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: AppTheme.gray300),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: AppTheme.gray300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: AppTheme.primary500, width: 2),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(color: AppTheme.error500),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        ),
                                        items: [
                                          const DropdownMenuItem<String>(
                                            value: '',
                                            child: Text('Select your college'),
                                          ),
                                          ..._colleges.map((college) {
                                            return DropdownMenuItem<String>(
                                              value: college.id,
                                              child: Text(college.name),
                                            );
                                          }),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCollegeId = value;
                                          });
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select a college';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                                  child: AppInput(
                                    label: 'Register Number',
                                    hintText: 'Enter your register number',
                                    controller: _registerNumberController,
                                    isRequired: true,
                                    validator: _validateRegisterNumber,
                                  ),
                                ),
                                SizedBox(
                                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                                  child: AppInput(
                                    label: 'Degree',
                                    hintText: 'e.g., B.Tech, B.E.',
                                    controller: _degreeController,
                                    isRequired: true,
                                    validator: _validateDegree,
                                  ),
                                ),
                                SizedBox(
                                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                                  child: AppInput(
                                    label: 'Department',
                                    hintText: 'e.g., Computer Science',
                                    controller: _departmentController,
                                    isRequired: true,
                                    validator: _validateDepartment,
                                  ),
                                ),
                                SizedBox(
                                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                                  child: AppInput(
                                    label: 'Passed Out Year',
                                    hintText: 'e.g., 2025',
                                    controller: _passedOutYearController,
                                    keyboardType: TextInputType.number,
                                    isRequired: true,
                                    validator: _validatePassedOutYear,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Submit Button
                        AppButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          isLoading: _isLoading,
                          isFullWidth: true,
                          child: const Text('Register'),
                        ),

                        const SizedBox(height: 24),

                        // Links
                        Column(
                          children: [
                            Text.rich(
                              TextSpan(
                                text: 'Already have an account? ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.gray600,
                                ),
                                children: [
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => context.go(AppConstants.routeStudentLogin),
                                      child: const Text(
                                        'Login here',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.primary600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => context.go(AppConstants.routeHome),
                              child: const Text(
                                '← Back to Home',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.gray500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
