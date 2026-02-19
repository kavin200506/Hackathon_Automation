import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../store/auth_store.dart';

class _SidebarItem {
  final IconData icon;
  final String label;
  final String route;

  _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class AppSidebar extends StatelessWidget {
  final String userType;
  final String currentRoute;

  const AppSidebar({
    super.key,
    required this.userType,
    required this.currentRoute,
  });

  List<_SidebarItem> _getMenuItems() {
    switch (userType) {
      case AppConstants.userTypeStudent:
        return [
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            route: AppConstants.routeStudentDashboard,
          ),
          _SidebarItem(
            icon: Icons.add_circle_outline,
            label: 'Create Team',
            route: AppConstants.routeStudentCreateTeam,
          ),
          _SidebarItem(
            icon: Icons.groups_outlined,
            label: 'My Teams',
            route: AppConstants.routeStudentMyTeams,
          ),
          _SidebarItem(
            icon: Icons.event_available_outlined,
            label: 'Join Hackathon',
            route: AppConstants.routeStudentJoinHackathon,
          ),
          _SidebarItem(
            icon: Icons.campaign_outlined,
            label: 'Announcements',
            route: AppConstants.routeStudentAnnouncements,
          ),
        ];

      case AppConstants.userTypeCollege:
        return [
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            route: AppConstants.routeCollegeDashboard,
          ),
          _SidebarItem(
            icon: Icons.add_circle_outline,
            label: 'Create Dept',
            route: AppConstants.routeCollegeCreateDepartment,
          ),
          _SidebarItem(
            icon: Icons.apartment_outlined,
            label: 'Departments',
            route: AppConstants.routeCollegeViewDepartments,
          ),
          _SidebarItem(
            icon: Icons.groups_outlined,
            label: 'All Teams',
            route: AppConstants.routeCollegeViewTeams,
          ),
        ];

      case AppConstants.userTypeDepartment:
        return [
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            route: AppConstants.routeDepartmentDashboard,
          ),
          _SidebarItem(
            icon: Icons.groups_outlined,
            label: 'My Teams',
            route: AppConstants.routeDepartmentViewTeams,
          ),
        ];

      case AppConstants.userTypeAdmin:
        return [
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            route: AppConstants.routeAdminDashboard,
          ),
          _SidebarItem(
            icon: Icons.add_circle_outline,
            label: 'Create Hackathon',
            route: AppConstants.routeAdminCreateHackathon,
          ),
          _SidebarItem(
            icon: Icons.topic_outlined,
            label: 'Topics',
            route: AppConstants.routeAdminManageTopics,
          ),
          _SidebarItem(
            icon: Icons.campaign_outlined,
            label: 'Announcements',
            route: AppConstants.routeAdminManageAnnouncements,
          ),
          _SidebarItem(
            icon: Icons.account_balance_outlined,
            label: 'Colleges',
            route: AppConstants.routeAdminViewColleges,
          ),
          _SidebarItem(
            icon: Icons.groups_outlined,
            label: 'All Teams',
            route: AppConstants.routeAdminViewTeams,
          ),
        ];

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Cathon',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userType.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ...menuItems.map((item) {
                  final isSelected = currentRoute == item.route;
                  return ListTile(
                    leading: Icon(
                      item.icon,
                      color: isSelected
                          ? AppTheme.primary600
                          : AppTheme.gray600,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.primary600
                            : AppTheme.gray800,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppTheme.primary50,
                    tileColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      context.go(item.route);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: AppTheme.error600,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: AppTheme.error600,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              final authStore = Provider.of<AuthStore>(context, listen: false);
              await authStore.logout();
              if (context.mounted) {
                Navigator.pop(context);
                context.go(AppConstants.routeHome);
              }
            },
          ),
        ],
      ),
    );
  }
}
