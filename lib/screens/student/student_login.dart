import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/validators.dart';
import '../../../services/auth_api.dart';
import '../../../store/auth_store.dart';
import '../../../models/user.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_input.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
      final response = await AuthAPI.studentLogin({
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });

      final authStore = Provider.of<AuthStore>(context, listen: false);
      final user = User.fromJson(response['user']);
      await authStore.setAuth(
        user,
        response['access'],
        AppConstants.userTypeStudent,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.refreshTokenKey, response['refresh']);

      if (!mounted) return;
      ErrorHandler.showSuccess('Login successful!');
      if (mounted) {
        context.go(AppConstants.routeStudentDashboard);
      }
    } catch (error) {
      // Mock auth fallback
      if (_emailController.text.trim() == 'student@test.com' &&
          _passwordController.text == '12345678') {
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
        if (mounted) {
          debugPrint('Navigating to dashboard: ${AppConstants.routeStudentDashboard}');
          context.go(AppConstants.routeStudentDashboard);
          debugPrint('Navigation completed');
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary50, Colors.white, AppTheme.secondary50],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AppCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.login, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 24),
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                        child: const Text(
                          'Student Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Welcome back! Sign in to your account',
                        style: TextStyle(color: AppTheme.gray600),
                      ),
                      const SizedBox(height: 32),
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
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        isFullWidth: true,
                        isLoading: _isLoading,
                        onPressed: _handleLogin,
                        child: const Text('Sign In'),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => context.go(AppConstants.routeStudentRegister),
                        child: const Text('Don\'t have an account? Register here'),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppConstants.routeHome),
                        child: const Text('← Back to Home'),
                      ),
                    ],
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


