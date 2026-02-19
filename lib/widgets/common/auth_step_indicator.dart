import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AuthStepIndicator extends StatelessWidget {
  final int currentStep;

  const AuthStepIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStep(1, 'Register'),
            _buildConnector(1),
            _buildStep(2, 'Verify OTP'),
            _buildConnector(2),
            _buildStep(3, 'Set Password'),
          ],
        ),
      ],
    );
  }

  Widget _buildStep(int stepNumber, String label) {
    final bool isActive = currentStep >= stepNumber;

    final Color circleBg = isActive ? AppTheme.primary600 : AppTheme.gray200;
    final Color circleText = isActive ? Colors.white : AppTheme.gray500;
    final Color labelColor = isActive ? AppTheme.primary600 : AppTheme.gray400;
    final FontWeight labelWeight = isActive ? FontWeight.w600 : FontWeight.normal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: TextStyle(
              color: circleText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: labelWeight,
            color: labelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(int beforeStepNumber) {
    final bool isCompleted = currentStep > beforeStepNumber;
    final Color lineColor = isCompleted ? AppTheme.primary600 : AppTheme.gray200;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: 24,
      height: 2,
      color: lineColor,
    );
  }
}


