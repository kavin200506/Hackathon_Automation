import 'package:flutter/material.dart';
import '../../core/theme.dart';

enum ButtonVariant { primary, secondary, success, danger, outline }

class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final bool isDisabled;

  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final content = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : child;

    Widget button = ElevatedButton(
      onPressed: (isDisabled || isLoading) ? null : onPressed,
      style: buttonStyle,
      child: content,
    );

    if (variant == ButtonVariant.outline) {
      button = OutlinedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: buttonStyle,
        child: content,
      );
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.gray200,
          foregroundColor: AppTheme.gray800,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        );
      case ButtonVariant.success:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.success600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        );
      case ButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.error600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        );
      case ButtonVariant.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primary600,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: AppTheme.primary600, width: 2),
        );
    }
  }
}




