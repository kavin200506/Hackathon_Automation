import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

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
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top hero section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Cathon',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hackathon Management Platform',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom panel
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Continue as',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.gray800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Select your role to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.gray500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView(
                            children: [
                              _RoleCard(
                                icon: Icons.school_rounded,
                                title: 'Student',
                                subtitle:
                                    'Join hackathons, create teams & submit projects',
                                color: AppTheme.primary600,
                                bgColor: AppTheme.primary50,
                                onTap: () =>
                                    context.go(AppConstants.routeStudentLogin),
                              ),
                              const SizedBox(height: 12),
                              _RoleCard(
                                icon: Icons.account_balance_rounded,
                                title: 'College',
                                subtitle:
                                    'Manage departments & monitor student activity',
                                color: AppTheme.success600,
                                bgColor: AppTheme.success50,
                                onTap: () =>
                                    context.go(AppConstants.routeCollegeLogin),
                              ),
                              const SizedBox(height: 12),
                              _RoleCard(
                                icon: Icons.apartment_rounded,
                                title: 'Department',
                                subtitle:
                                    'Track teams & participation in your department',
                                color: const Color(0xFFD97706),
                                bgColor: const Color(0xFFFFFBEB),
                                onTap: () => context
                                    .go(AppConstants.routeDepartmentLogin),
                              ),
                              const SizedBox(height: 12),
                              _RoleCard(
                                icon: Icons.admin_panel_settings_rounded,
                                title: 'Admin',
                                subtitle:
                                    'Manage hackathons, topics & announcements',
                                color: AppTheme.error600,
                                bgColor: AppTheme.error50,
                                onTap: () =>
                                    context.go(AppConstants.routeAdminLogin),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

