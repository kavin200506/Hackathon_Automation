import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../models/user.dart';
import '../../../services/department_api.dart';
import '../../../store/auth_store.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_loader.dart';
import '../../../widgets/common/app_sidebar.dart';

class DepartmentDashboardScreen extends StatefulWidget {
  const DepartmentDashboardScreen({super.key});

  @override
  State<DepartmentDashboardScreen> createState() =>
      _DepartmentDashboardScreenState();
}

class _DepartmentDashboardScreenState
    extends State<DepartmentDashboardScreen> {
  bool _isLoading = true;
  List<dynamic> _teams = [];
  User? _user;
  String _searchQuery = '';
  String _filter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      _user = authStore.user;

      final teams = await DepartmentAPI.getTeams();
      setState(() {
        _teams = teams;
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);
      // Mock data fallback
      setState(() {
        _teams = [
          {
            'id': 'team-1',
            'team_name': 'Team Alpha',
            'leader_name': 'John Doe',
            'payment_status': 'PAID',
            'hackathon': {'name': 'AI Challenge'},
            'members': [
              {'name': 'John Doe'},
              {'name': 'Jane Smith'},
            ],
          },
          {
            'id': 'team-2',
            'team_name': 'Team Beta',
            'leader_name': 'Alice Johnson',
            'payment_status': 'UNPAID',
            'hackathon': {'name': 'Tech Innovation'},
            'members': [
              {'name': 'Alice Johnson'},
            ],
          },
          {
            'id': 'team-3',
            'team_name': 'Team Gamma',
            'leader_name': 'Bob Wilson',
            'payment_status': 'PAID',
            'hackathon': null,
            'members': [
              {'name': 'Bob Wilson'},
              {'name': 'Carol Brown'},
            ],
          },
        ];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> get _filteredTeams {
    final q = _searchQuery.trim().toLowerCase();
    return _teams.where((team) {
      final map = team as Map<String, dynamic>;
      final status = (map['payment_status'] ?? '').toString().toUpperCase();
      final name = (map['team_name'] ?? '').toString().toLowerCase();

      final matchesFilter = _filter == 'ALL' || status == _filter;
      final matchesSearch = q.isEmpty || name.contains(q);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  int get _totalTeams => _teams.length;
  int get _paidTeams =>
      _teams.where((t) => (t['payment_status'] ?? '').toString().toUpperCase() == 'PAID').length;
  int get _unpaidTeams => _totalTeams - _paidTeams;
  int get _activeHackathons =>
      _teams.where((t) => t['hackathon'] != null).length;

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _filter = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: AppLoader());
    }

    final teams = _filteredTeams;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Department Dashboard'),
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.gray900),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.gray600),
            onPressed: () async {
              final authStore = Provider.of<AuthStore>(context, listen: false);
              await authStore.logout();
              if (!mounted) return;
              context.go(AppConstants.routeHome);
            },
          ),
        ],
      ),
      drawer: AppSidebar(
        userType: AppConstants.userTypeDepartment,
        currentRoute: AppConstants.routeDepartmentDashboard,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFF4E6),
                      Color(0xFFFFF8F0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${_user?.name ?? 'Department'}! 🏛️',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Track teams and participation',
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
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '$_totalTeams',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Total Teams',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '$_paidTeams',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.success600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Paid',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '$_unpaidTeams',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warning600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Unpaid',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '$_activeHackathons',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Active Hackathons',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Teams',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gray900,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(AppConstants.routeDepartmentViewTeams),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Filter bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'ALL'),
                  _buildFilterChip('Paid', 'PAID'),
                  _buildFilterChip('Unpaid', 'UNPAID'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search teams...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.gray300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.gray300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppTheme.primary500,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Teams list (first 3)
            if (teams.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No teams found',
                    style: TextStyle(color: AppTheme.gray500),
                  ),
                ),
              )
            else
              ...teams.take(3).map((team) {
                final map = team as Map<String, dynamic>;
                final teamName = (map['team_name'] ?? '').toString();
                final leaderName = (map['leader_name'] ?? '').toString();
                final hackathonName = (map['hackathon']?['name'] ?? '').toString();
                final status = (map['payment_status'] ?? 'UNPAID').toString().toUpperCase();
                final members = (map['members'] as List?) ?? [];

                final isPaid = status == 'PAID';

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
                              teamName,
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
                              color: isPaid
                                  ? AppTheme.success50
                                  : AppTheme.warning50,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isPaid
                                    ? AppTheme.success700
                                    : AppTheme.warning600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Leader: $leaderName',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.gray600,
                        ),
                      ),
                      if (hackathonName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.emoji_events_outlined,
                              size: 16,
                              color: AppTheme.gray500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              hackathonName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.gray600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Members: ${members.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.gray600,
                        ),
                      ),
                    ],
                    ),
                  ),
                );
              }),
            if (teams.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton(
                    onPressed: () => context.go(AppConstants.routeDepartmentViewTeams),
                    child: const Text('View All Teams'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
