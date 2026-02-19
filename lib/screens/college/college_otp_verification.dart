import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../services/auth_api.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/auth_step_indicator.dart';

class CollegeOTPVerificationScreen extends StatefulWidget {
  const CollegeOTPVerificationScreen({super.key});

  @override
  State<CollegeOTPVerificationScreen> createState() =>
      _CollegeOTPVerificationScreenState();
}

class _CollegeOTPVerificationScreenState
    extends State<CollegeOTPVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  String _email = '';
  int _resendCountdown = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _loadEmail();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('college_email') ?? '';
    });
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          _resendCountdown--;
        });
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    if (_otp.length != 6) {
      ErrorHandler.showError('Please enter the complete 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthAPI.collegeVerifyOTP({
        'email': _email,
        'otp': _otp,
      });

      if (!mounted) return;
      ErrorHandler.showSuccess('OTP verified! Set your password.');
      context.go(AppConstants.routeCollegeSetPassword);
    } catch (error) {
      ErrorHandler.handleAPIError(error);
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0 || _email.isEmpty) return;

    setState(() => _isResending = true);

    try {
      await AuthAPI.collegeRegister({
        'email': _email,
        'resend_otp': true,
      });

      if (!mounted) return;
      ErrorHandler.showSuccess('OTP resent to $_email');
      _startResendTimer();
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    } catch (error) {
      ErrorHandler.handleAPIError(error);
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_otp.length == 6) {
      _handleVerify();
    }
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppTheme.gray300,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppTheme.gray300,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppTheme.primary500,
              width: 2.5,
            ),
          ),
        ),
        onChanged: (value) => _onOtpChanged(index, value),
      ),
    );
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () =>
                            context.go(AppConstants.routeCollegeRegister),
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
                      ),
                    ),
                    const AuthStepIndicator(currentStep: 2),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppTheme.primary50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.mark_email_read_outlined,
                              size: 36,
                              color: AppTheme.primary600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Verify Your Email',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter the 6-digit OTP sent to',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.gray500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _email.isEmpty ? 'your email' : _email,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary600,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:
                                List.generate(6, (index) => _buildOtpBox(index)),
                          ),
                          const SizedBox(height: 32),
                          AppButton(
                            isFullWidth: true,
                            isLoading: _isLoading,
                            onPressed: _handleVerify,
                            child: const Text(
                              'Verify OTP',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Didn\'t receive OTP? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.gray600,
                                ),
                              ),
                              if (_resendCountdown > 0)
                                Text(
                                  'Resend in ${_resendCountdown}s',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.gray400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap:
                                      _isResending ? null : () => _handleResend(),
                                  child: Text(
                                    _isResending ? 'Sending...' : 'Resend OTP',
                                    style: const TextStyle(
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












