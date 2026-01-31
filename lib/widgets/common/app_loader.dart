import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AppLoader extends StatelessWidget {
  final bool isFullScreen;
  final double size;

  const AppLoader({
    super.key,
    this.isFullScreen = true,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final loader = SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(
        strokeWidth: 4,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary600),
      ),
    );

    if (isFullScreen) {
      return Scaffold(
        backgroundColor: AppTheme.gray50,
        body: Center(child: loader),
      );
    }

    return Center(child: loader);
  }
}






