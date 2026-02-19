import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils/error_handler.dart';
import '../../models/user.dart';
import '../../models/department.dart';
import '../../models/team.dart';
import '../../services/college_api.dart';
import '../../store/auth_store.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/app_sidebar.dart';

class CollegeDashboardScreen extends StatefulWidget {
  const CollegeDashboardScreen({super.key});

  @override
  State<CollegeDashboardScreen> createState() => _CollegeDashboardScreenState();
}

class _CollegeDashboardScreenState extends State<CollegeDashboardScreen> {
  bool _isLoading = true;
  List<Department> _departments = [];
  List<Team> _teams = [];
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      _user = authStore.user;

      final departmentsResponse = await CollegeAPI.getDepartments();
      final departments = departmentsResponse
          .map((d) => Department.fromJson(d))
          .toList();

      final teamsResponse = await CollegeAPI.getTeams();
      final teams = teamsResponse
          .map((t) => Team.fromJson(t))
          .toList();

      setState(() {
        _departments = departments;
        _teams = teams;
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);

      // Mock data
      final mockDepartments = [
        Department(
          id: '1',
          name: 'Computer Science',
          teamCount: 5,
        ),
        Department(
          id: '2',
          name: 'Electronics',
          teamCount: 3,
        ),
      ];

      final mockTeams = [
        Team(
          id: '1',
          teamName: 'Team Alpha',
          paymentStatus: 'PAID',
          createdAt: DateTime.now(),
        ),
        Team(
          id: '2',
          teamName: 'Team Beta',
          paymentStatus: 'UNPAID',
          createdAt: DateTime.now(),
        ),
        Team(
          id: '3',
          teamName: 'Team Gamma',
          paymentStatus: 'PAID',
          createdAt: DateTime.now(),
        ),
        Team(
          id: '4',
          teamName: 'Team Delta',
          paymentStatus: 'UNPAID',
          createdAt: DateTime.now(),
        ),
      ];

      setState(() {
        _departments = mockDepartments;
        _teams = mockTeams;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStore = Provider.of<AuthStore>(context);
    _user ??= authStore.user;

    if (_isLoading) {
      return const AppLoader();
    }

    final collegeName = _user?.name ?? 'College';
    final totalDepartments = _departments.length;
    final totalTeams = _teams.length;
    final paidTeams = _teams.where((t) => t.paymentStatus == 'PAID').length;
    final unpaidTeams = totalTeams - paidTeams;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('College Dashboard'),
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
        userType: AppConstants.userTypeCollege,
        currentRoute: AppConstants.routeCollegeDashboard,
      ),
      body: Container(
        color: AppTheme.gray50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.success50, AppTheme.primary50],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $collegeName! 🏛️',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage your institution',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Stats grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _StatCard(
                    count: totalDepartments,
                    label: 'Total Departments',
                    color: AppTheme.primary600,
                  ),
                  _StatCard(
                    count: totalTeams,
                    label: 'Total Teams',
                    color: AppTheme.success600,
                  ),
                  _StatCard(
                    count: paidTeams,
                    label: 'Paid Teams',
                    color: AppTheme.success600,
                  ),
                  _StatCard(
                    count: unpaidTeams,
                    label: 'Pending Payment',
                    color: AppTheme.warning600,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Departments section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Departments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gray900,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppConstants.routeCollegeViewDepartments),
                    child: const Text('Manage'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: _departments.isEmpty
                    ? Center(
                        child: Text(
                          'No departments yet',
                          style: TextStyle(color: AppTheme.gray500),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _departments.length,
                        itemBuilder: (context, index) {
                          final dept = _departments[index];
                          return Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 12),
                            child: AppCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dept.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.gray900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: AppTheme.gray600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'HOD: TBD',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.gray600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              // Recent teams section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Teams',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gray900,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppConstants.routeCollegeViewTeams),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_teams.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No teams yet',
                      style: TextStyle(color: AppTheme.gray500),
                    ),
                  ),
                )
              else
                ..._teams.take(3).map((team) {
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
                                  team.teamName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.gray900,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: team.paymentStatus == 'PAID'
                                      ? AppTheme.success50
                                      : AppTheme.warning50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  team.paymentStatus,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: team.paymentStatus == 'PAID'
                                        ? AppTheme.success700
                                        : AppTheme.warning600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (team.members != null && team.members!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Department: TBD',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.gray600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppConstants.routeCollegeCreateDepartment),
        icon: const Icon(Icons.add_business),
        label: const Text('New Department'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatCard({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
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
}
