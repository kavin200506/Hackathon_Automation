import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class MenuItem {
  final String label;
  final String path;
  final IconData? icon;
  final VoidCallback? onTap;

  MenuItem({
    required this.label,
    required this.path,
    this.icon,
    this.onTap,
  });
}

class AppSidebar extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final List<MenuItem> menuItems;
  final String userType;

  const AppSidebar({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.menuItems,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final currentPath = router.routerDelegate.currentConfiguration.uri.path;

    return Container(
      width: 256,
      color: Colors.white,
      child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.gray200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                    child: const Text(
                      'Cathon',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: menuItems.map((item) {
                  final isActive = currentPath == item.path;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary100 : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: item.icon != null
                          ? Icon(
                              item.icon,
                              color: isActive
                                  ? AppTheme.primary700
                                  : AppTheme.gray700,
                            )
                          : null,
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: isActive
                              ? AppTheme.primary700
                              : AppTheme.gray700,
                          fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        if (item.onTap != null) {
                          item.onTap!();
                        } else {
                          context.go(item.path);
                        }
                        onClose();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.gray200),
                ),
              ),
              child: Text(
                '${userType.toUpperCase()} Portal',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray500,
                ),
              ),
            ),
          ],
        ),
    );
  }
}

