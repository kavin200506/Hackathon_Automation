import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/validators.dart';
import '../../../models/user.dart';
import '../../../services/auth_api.dart';
import '../../../store/auth_store.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_input.dart';
import '../../../widgets/common/auth_step_indicator.dart';

class CollegeSetPasswordScreen extends StatefulWidget {
  const CollegeSetPasswordScreen({super.key});

  @override
  State<CollegeSetPasswordScreen> createState() =>
      _CollegeSetPasswordScreenState();
}

class _CollegeSetPasswordScreenState extends State<CollegeSetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('college_email') ?? '';
    });
  }

  Future<void> _handleSetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Set password
      await AuthAPI.collegeSetPassword({
        'email': _email,
        'password': _passwordController.text,
      });

      // Step 2: Auto-login
      final loginResponse = await AuthAPI.collegeLogin({
        'email': _email,
        'password': _passwordController.text,
      });

      if (!mounted) return;

      final userJson =
          (loginResponse['college'] ?? loginResponse['user'] ?? {})
              as Map<String, dynamic>;
      final user = User.fromJson(userJson);

      final token =
          (loginResponse['access_token'] ?? loginResponse['token'] ?? '')
              as String;

      final authStore = Provider.of<AuthStore>(context, listen: false);
      await authStore.setAuth(
        user,
        token,
        AppConstants.userTypeCollege,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('college_email');

      if (!mounted) return;
      ErrorHandler.showSuccess('Account created! Welcome, ${user.name}! 🎉');
      context.go(AppConstants.routeCollegeDashboard);
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
              AppTheme.success50,
              Colors.white,
              AppTheme.success100,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          context.go(AppConstants.routeCollegeVerifyOtp),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: AppTheme.gray600,
                      ),
                      label: const Text(
                        'Back',
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
                    const AuthStepIndicator(currentStep: 3),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppTheme.success50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.lock_reset_outlined,
                                size: 36,
                                color: AppTheme.success600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Set Your Password',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gray900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Almost done! Create a secure password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.gray500,
                              ),
                            ),
                            const SizedBox(height: 28),
                            AppInput(
                              label: 'Password',
                              hintText: 'Minimum 8 characters',
                              controller: _passwordController,
                              isObscure: _obscurePassword,
                              validator: Validators.validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppTheme.gray500,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppInput(
                              label: 'Confirm Password',
                              hintText: 'Re-enter your password',
                              controller: _confirmPasswordController,
                              isObscure: _obscureConfirmPassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppTheme.gray500,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              isFullWidth: true,
                              isLoading: _isLoading,
                              onPressed: _handleSetPassword,
                              child: const Text(
                                'Create Account & Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
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












