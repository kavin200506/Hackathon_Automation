import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../widgets/common/app_card.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              child: const Center(
                child: Column(
                  children: [
                    Text(
                      'Cathon Hackathon Platform',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Empowering Innovation Through Collaborative Hackathons',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 48) / 4; // 48 = 3 gaps of 16px
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _UserTypeCard(
                          title: 'Student',
                          description: 'Join hackathons, create teams',
                          icon: Icons.people,
                          color: AppTheme.primary600,
                          onTap: () => context.go('/student/login'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: cardWidth,
                        child: _UserTypeCard(
                          title: 'College',
                          description: 'Manage departments',
                          icon: Icons.school,
                          color: AppTheme.success600,
                          onTap: () => context.go('/college/login'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: cardWidth,
                        child: _UserTypeCard(
                          title: 'Department',
                          description: 'View team activities',
                          icon: Icons.business,
                          color: AppTheme.warning600,
                          onTap: () => context.go('/department/login'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: cardWidth,
                        child: _UserTypeCard(
                          title: 'Admin',
                          description: 'Full system control',
                          icon: Icons.admin_panel_settings,
                          color: AppTheme.error600,
                          onTap: () => context.go('/admin/login'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      enableHover: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

