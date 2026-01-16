import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AppModal extends StatelessWidget {
  final Widget child;
  final String? title;
  final VoidCallback? onClose;
  final bool isOpen;

  const AppModal({
    super.key,
    required this.child,
    this.title,
    this.onClose,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null || onClose != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.gray200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gray800,
                          ),
                        ),
                      if (onClose != null)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onClose,
                        ),
                    ],
                  ),
                ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




