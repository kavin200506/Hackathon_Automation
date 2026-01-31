import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool enableHover;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.enableHover = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24),
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    if (enableHover) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: card,
      );
    }

    return card;
  }
}






