import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils/error_handler.dart';
import '../../services/admin_api.dart';
import '../../store/auth_store.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/app_sidebar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  List<dynamic> _hackathons = [];
  List<dynamic> _colleges = [];
  List<dynamic> _teams = [];
  List<dynamic> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        AdminAPI.getHackathons(),
        AdminAPI.getColleges(),
        AdminAPI.getTeams(),
        AdminAPI.getAnnouncements(),
      ]);

      setState(() {
        _hackathons = results[0];
        _colleges = results[1];
        _teams = results[2];
        _announcements = results[3];
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);
      // Mock data fallback
      setState(() {
        _hackathons = List.generate(2, (i) => {
          'id': 'hack-${i + 1}',
          'name': 'Hackathon ${i + 1}',
          'start_date': DateTime.now().add(Duration(days: i * 10)).toIso8601String(),
          'end_date': DateTime.now().add(Duration(days: i * 10 + 3)).toIso8601String(),
          'status': i == 0 ? 'ACTIVE' : 'UPCOMING',
          'team_count': (i + 1) * 5,
        });
        _colleges = List.generate(5, (i) => {'id': 'col-${i + 1}', 'name': 'College ${i + 1}'});
        _teams = List.generate(20, (i) => {'id': 'team-${i + 1}', 'name': 'Team ${i + 1}'});
        _announcements = List.generate(3, (i) => {'id': 'ann-${i + 1}', 'title': 'Announcement ${i + 1}'});
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final startStr = DateFormat('MMM dd').format(start);
    final endStr = DateFormat('MMM dd, yyyy').format(end);
    return '$startStr - $endStr';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
      resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: const AppLoader(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.gray900),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.gray600),
            onPressed: () async {
              final authStore = Provider.of<AuthStore>(context, listen: false);
              await authStore.logout();
              if (context.mounted) {
                context.go(AppConstants.routeHome);
              }
            },
          ),
        ],
      ),
      drawer: AppSidebar(
        userType: AppConstants.userTypeAdmin,
        currentRoute: AppConstants.routeAdminDashboard,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            AppCard(
              padding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.error50,
                      AppTheme.error100,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Panel 👨‍💼',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage the entire platform',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Stats grid (2x2)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildStatCard(
                  icon: Icons.emoji_events,
                  count: _hackathons.length,
                  label: 'Total Hackathons',
                  color: AppTheme.primary600,
                ),
                _buildStatCard(
                  icon: Icons.account_balance,
                  count: _colleges.length,
                  label: 'Total Colleges',
                  color: AppTheme.success600,
                ),
                _buildStatCard(
                  icon: Icons.groups,
                  count: _teams.length,
                  label: 'Total Teams',
                  color: AppTheme.secondary600,
                ),
                _buildStatCard(
                  icon: Icons.campaign,
                  count: _announcements.length,
                  label: 'Announcements',
                  color: AppTheme.warning600,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildActionCard(
                  icon: Icons.add_circle,
                  label: 'Create Hackathon',
                  color: AppTheme.primary600,
                  onTap: () => context.go(AppConstants.routeAdminCreateHackathon),
                ),
                _buildActionCard(
                  icon: Icons.topic,
                  label: 'Manage Topics',
                  color: AppTheme.success600,
                  onTap: () => context.go(AppConstants.routeAdminManageTopics),
                ),
                _buildActionCard(
                  icon: Icons.campaign,
                  label: 'Announcements',
                  color: AppTheme.warning600,
                  onTap: () => context.go(AppConstants.routeAdminManageAnnouncements),
                ),
                _buildActionCard(
                  icon: Icons.school,
                  label: 'View Colleges',
                  color: AppTheme.gray600,
                  onTap: () => context.go(AppConstants.routeAdminViewColleges),
                ),
                _buildActionCard(
                  icon: Icons.groups,
                  label: 'View All Teams',
                  color: AppTheme.error600,
                  onTap: () => context.go(AppConstants.routeAdminViewTeams),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Active Hackathons
            const Text(
              'Active Hackathons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),
            const SizedBox(height: 12),
            if (_hackathons.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No hackathons yet',
                    style: TextStyle(color: AppTheme.gray500),
                  ),
                ),
              )
            else
              ..._hackathons.take(2).map((hackathon) {
                final map = hackathon as Map<String, dynamic>;
                final name = (map['name'] ?? '').toString();
                final startDate = map['start_date'] != null
                    ? DateTime.parse(map['start_date'].toString())
                    : DateTime.now();
                final endDate = map['end_date'] != null
                    ? DateTime.parse(map['end_date'].toString())
                    : DateTime.now();
                final status = (map['status'] ?? 'INACTIVE').toString().toUpperCase();
                final teamCount = map['team_count'] ?? map['teams_count'] ?? 0;

                final isActive = status == 'ACTIVE';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppTheme.success50
                                  : AppTheme.gray100,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? AppTheme.success700
                                    : AppTheme.gray600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDateRange(startDate, endDate),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.gray600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.groups_outlined,
                            size: 16,
                            color: AppTheme.gray500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Teams: $teamCount',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.gray600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.gray600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
