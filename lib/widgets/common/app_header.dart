import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../store/auth_store.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final String title;

  const AppHeader({
    super.key,
    this.onMenuTap,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStore>(
      builder: (context, authStore, _) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              if (onMenuTap != null)
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: onMenuTap,
                  color: AppTheme.gray800,
                ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gray800,
                  ),
                ),
              ),
              Row(
                children: [
                  if (authStore.user != null) ...[
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          authStore.user!.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.gray800,
                          ),
                        ),
                        Text(
                          authStore.user!.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primary100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.primary600,
                        size: 20,
                      ),
                    ),
                  ],
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.logout, color: AppTheme.error600),
                    onPressed: () async {
                      await authStore.logout();
                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

