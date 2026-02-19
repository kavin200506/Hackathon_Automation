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

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final response = await AuthAPI.studentLogin({
        'email': email,
        'password': password,
      });

      if (!mounted) return;

      final authStore = Provider.of<AuthStore>(context, listen: false);
      final userJson =
          (response['user'] ?? response['student'] ?? {}) as Map<String, dynamic>;
      final user = User.fromJson(userJson);

      final token =
          (response['access_token'] ?? response['token'] ?? '') as String;

      await authStore.setAuth(
        user,
        token,
        AppConstants.userTypeStudent,
      );

      if (!mounted) return;
      ErrorHandler.showSuccess('Welcome back, ${user.name}!');
      context.go(AppConstants.routeStudentDashboard);
    } catch (error) {
      // Mock login fallback
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email == 'student@test.com' && password == '12345678') {
        final authStore = Provider.of<AuthStore>(context, listen: false);
        final mockUser = User(
          id: 'mock-1',
          name: 'Mock Student',
          email: 'student@test.com',
        );

        await authStore.setAuth(
          mockUser,
          'mock-access-token',
          AppConstants.userTypeStudent,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.refreshTokenKey, 'mock-refresh-token');

        if (!mounted) return;
        ErrorHandler.showSuccess('Mock login successful!');
        context.go(AppConstants.routeStudentDashboard);
      } else {
        ErrorHandler.handleAPIError(error);
      }
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
              AppTheme.primary50,
              Colors.white,
              AppTheme.secondary50,
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.go(AppConstants.routeHome),
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
                    const SizedBox(height: 8),
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
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Student Login',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gray900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Welcome back! Sign in to continue',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.gray500,
                              ),
                            ),
                            const SizedBox(height: 28),
                            AppInput(
                              label: 'Email Address',
                              hintText: 'Enter your email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            AppInput(
                              label: 'Password',
                              hintText: 'Enter your password',
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
                                  setState(
                                      () => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              isFullWidth: true,
                              isLoading: _isLoading,
                              onPressed: _handleLogin,
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Don\'t have an account? ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.gray600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context
                                      .go(AppConstants.routeStudentRegister),
                                  child: const Text(
                                    'Register',
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
