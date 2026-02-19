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

class DepartmentLoginScreen extends StatefulWidget {
  const DepartmentLoginScreen({super.key});

  @override
  State<DepartmentLoginScreen> createState() => _DepartmentLoginScreenState();
}

class _DepartmentLoginScreenState extends State<DepartmentLoginScreen> {
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

      final response = await AuthAPI.departmentLogin({
        'email': email,
        'password': password,
      });

      final authStore = Provider.of<AuthStore>(context, listen: false);
      final user = User.fromJson(response['user'] ?? response['department'] ?? {});
      final token = response['access_token'] ?? response['token'] ?? '';

      await authStore.setAuth(user, token, AppConstants.userTypeDepartment);

      if (!mounted) return;
      ErrorHandler.showSuccess('Welcome back, ${user.name}!');
      if (mounted) {
        context.go(AppConstants.routeDepartmentDashboard);
      }
    } catch (error) {
      // Mock login fallback
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email == 'department@test.com' && password == '12345678') {
        final authStore = Provider.of<AuthStore>(context, listen: false);
        final mockUser = User(
          id: 'mock-d1',
          name: 'Department',
          email: 'department@test.com',
        );
        await authStore.setAuth(
          mockUser,
          'mock-access-token',
          AppConstants.userTypeDepartment,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.refreshTokenKey, 'mock-refresh-token');

        if (!mounted) return;
        ErrorHandler.showSuccess('Mock login successful!');
        if (mounted) {
          context.go(AppConstants.routeDepartmentDashboard);
        }
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
              Color(0xFFFFF4E6),
              Colors.white,
              Color(0xFFFFF8F0),
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
                  children: [
                    TextButton.icon(
                      onPressed: () => context.go(AppConstants.routeHome),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.gray600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.apartment_rounded,
                                size: 36,
                                color: Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Department Login',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gray900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Manage your department',
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
                              validator: Validators.validatePassword,
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              isFullWidth: true,
                              isLoading: _isLoading,
                              onPressed: _handleLogin,
                              child: const Text(
                                'Sign In',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Department credentials are provided by your college admin',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.gray500,
                              ),
                              textAlign: TextAlign.center,
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
