import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/utils/helpers.dart';
import '../../services/student_api.dart';
import '../../store/auth_store.dart';
import '../../models/user.dart';
import '../../models/team.dart';
import '../../models/announcement.dart';
import '../../models/hackathon.dart';
import '../../models/topic.dart';
import '../../models/member.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/app_sidebar.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/student/team_card.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _isLoading = true;
  bool _sidebarOpen = false;
  List<Team> _teams = [];
  List<Announcement> _announcements = [];

  @override
  void initState() {
    super.initState();
    debugPrint('StudentDashboard initState called');
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    debugPrint('Fetching dashboard data...');
    setState(() => _isLoading = true);

    try {
      // Try to fetch real data
      final profileData = await StudentAPI.getProfile();
      final teamsData = await StudentAPI.getMyTeams();
      final announcementsData = await StudentAPI.getAnnouncements();

      // Update user profile
      if (!mounted) return;
      final authStore = Provider.of<AuthStore>(context, listen: false);
      final user = User.fromJson(profileData);
      await authStore.setUser(user);

      // Parse teams
      final teams = teamsData
          .map((t) => Team.fromJson(t))
          .toList();

      // Parse announcements
      final announcements = announcementsData
          .map((a) => Announcement.fromJson(a))
          .toList();

      if (mounted) {
        setState(() {
          _teams = teams.take(3).toList();
          _announcements = announcements.take(5).toList();
        });
      }
    } catch (error) {
      // Use mock data on API failure
      debugPrint('API failed, using mock data: $error');
      
      if (!mounted) return;
      final authStore = Provider.of<AuthStore>(context, listen: false);
      
      // Mock user data
      final mockUser = User(
        id: 'mock-1',
        name: 'Mock Student',
        email: 'student@test.com',
      );
      await authStore.setUser(mockUser);

      // Mock teams data
      final mockTeams = [
        Team(
          id: 'team-1',
          teamName: 'Team Alpha',
          paymentStatus: 'PAID',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          hackathon: Hackathon(
            id: 'hack-1',
            name: 'Tech Innovation Hackathon',
            description: 'Annual tech innovation event',
            startDate: DateTime.now().add(const Duration(days: 10)),
            endDate: DateTime.now().add(const Duration(days: 12)),
            teamFee: 500.0,
            maxTeamSize: 5,
            status: 'ACTIVE',
          ),
          topic: Topic(
            id: 'topic-1',
            name: 'AI/ML Solutions',
          ),
          members: [
            Member(
              id: 'mem-1',
              name: 'Mock Student',
              email: 'student@test.com',
            ),
            Member(
              id: 'mem-2',
              name: 'John Doe',
              email: 'john@example.com',
            ),
          ],
          githubUrl: 'https://github.com/team-alpha/project',
        ),
        Team(
          id: 'team-2',
          teamName: 'Team Beta',
          paymentStatus: 'UNPAID',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          hackathon: Hackathon(
            id: 'hack-1',
            name: 'Tech Innovation Hackathon',
            description: 'Annual tech innovation event',
            startDate: DateTime.now().add(const Duration(days: 10)),
            endDate: DateTime.now().add(const Duration(days: 12)),
            teamFee: 500.0,
            maxTeamSize: 5,
            status: 'ACTIVE',
          ),
          members: [
            Member(
              id: 'mem-1',
              name: 'Mock Student',
              email: 'student@test.com',
            ),
          ],
        ),
      ];

      // Mock announcements
      final mockAnnouncements = [
        Announcement(
          id: 'ann-1',
          title: 'Welcome to Hackathon Platform',
          message: 'We are excited to have you here. Start creating teams and join hackathons!',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Announcement(
          id: 'ann-2',
          title: 'Payment Deadline Reminder',
          message: 'Please complete your team payments before the deadline to participate.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      if (mounted) {
        setState(() {
          _teams = mockTeams;
          _announcements = mockAnnouncements;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<MenuItem> get _menuItems => [
        MenuItem(
          label: 'Dashboard',
          path: AppConstants.routeStudentDashboard,
          icon: Icons.dashboard,
        ),
        MenuItem(
          label: 'My Teams',
          path: AppConstants.routeStudentMyTeams,
          icon: Icons.people,
        ),
        MenuItem(
          label: 'Create Team',
          path: AppConstants.routeStudentCreateTeam,
          icon: Icons.add,
        ),
        MenuItem(
          label: 'Join Hackathon',
          path: AppConstants.routeStudentJoinHackathon,
          icon: Icons.emoji_events,
        ),
        MenuItem(
          label: 'Announcements',
          path: AppConstants.routeStudentAnnouncements,
          icon: Icons.notifications,
        ),
        MenuItem(
          label: 'Logout',
          path: AppConstants.routeHome,
          icon: Icons.logout,
          onTap: () async {
            final authStore = Provider.of<AuthStore>(context, listen: false);
            await authStore.logout();
            if (mounted) {
              context.go(AppConstants.routeHome);
            }
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoader();
    }

    try {
      final authStore = Provider.of<AuthStore>(context);
      final user = authStore.user;

      // Debug: Check if user is null
      debugPrint('Dashboard - User: ${user?.name}, Teams: ${_teams.length}, Announcements: ${_announcements.length}');

    final stats = [
      _StatCard(
        title: 'My Teams',
        value: _teams.length,
        icon: Icons.people,
        gradient: const LinearGradient(
          colors: [AppTheme.primary500, AppTheme.primary600],
        ),
        bgColor: AppTheme.primary50,
        textColor: AppTheme.primary600,
      ),
      _StatCard(
        title: 'Hackathons Joined',
        value: _teams.where((t) => t.hackathon != null).length,
        icon: Icons.emoji_events,
        gradient: const LinearGradient(
          colors: [AppTheme.secondary500, AppTheme.secondary600],
        ),
        bgColor: AppTheme.secondary50,
        textColor: AppTheme.secondary600,
      ),
      _StatCard(
        title: 'Paid Teams',
        value: _teams.where((t) => t.paymentStatus == 'PAID').length,
        icon: Icons.check_circle,
        gradient: const LinearGradient(
          colors: [AppTheme.success500, AppTheme.success600],
        ),
        bgColor: AppTheme.success50,
        textColor: AppTheme.success600,
      ),
      _StatCard(
        title: 'Announcements',
        value: _announcements.length,
        icon: Icons.notifications,
        gradient: const LinearGradient(
          colors: [AppTheme.warning500, AppTheme.warning600],
        ),
        bgColor: AppTheme.warning50,
        textColor: AppTheme.warning600,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Sidebar - always visible on desktop, toggleable on mobile
              if (_sidebarOpen || MediaQuery.of(context).size.width >= 1024)
                SizedBox(
                  width: 256,
                  child: AppSidebar(
                    isOpen: _sidebarOpen,
                    onClose: () => setState(() => _sidebarOpen = false),
                    menuItems: _menuItems,
                    userType: 'student',
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    AppHeader(
                      onMenuTap: () => setState(() => _sidebarOpen = !_sidebarOpen),
                      title: 'Student Dashboard',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${user?.name ?? 'Student'}! 👋',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gray800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Here\'s what\'s happening with your hackathon journey',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.gray600,
                              ),
                            ),
                            const SizedBox(height: 32),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                int crossAxisCount = 4;
                                if (constraints.maxWidth < 1200) crossAxisCount = 3;
                                if (constraints.maxWidth < 900) crossAxisCount = 2;
                                if (constraints.maxWidth < 600) crossAxisCount = 1;
                                
                                return GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 1.2,
                                  children: stats,
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 1024) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildRecentTeams(context),
                                      const SizedBox(height: 24),
                                      _buildAnnouncements(context),
                                    ],
                                  );
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: _buildRecentTeams(context),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: _buildAnnouncements(context),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Overlay for mobile sidebar
          if (_sidebarOpen && MediaQuery.of(context).size.width < 1024)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _sidebarOpen = false),
                child: Container(
                  color: Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
    } catch (e, stackTrace) {
      debugPrint('Dashboard Error: $e');
      debugPrint('Stack: $stackTrace');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppTheme.error500),
              const SizedBox(height: 16),
              Text('Error loading dashboard: $e'),
              const SizedBox(height: 16),
              AppButton(
                onPressed: () => _fetchDashboardData(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildRecentTeams(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Teams',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray800,
              ),
            ),
            AppButton(
              variant: ButtonVariant.outline,
              onPressed: () => context.go(AppConstants.routeStudentMyTeams),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility, size: 16),
                  SizedBox(width: 4),
                  Text('View All'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_teams.isEmpty)
          AppCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.people,
                  size: 64,
                  color: AppTheme.gray300,
                ),
                const SizedBox(height: 16),
                const Text(
                  'You haven\'t created any teams yet',
                  style: TextStyle(
                    color: AppTheme.gray600,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  onPressed: () =>
                      context.go(AppConstants.routeStudentCreateTeam),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16),
                      SizedBox(width: 4),
                      Text('Create Your First Team'),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ..._teams.map((team) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TeamCardWidget(team: team),
              )),
      ],
    );
  }

  Widget _buildAnnouncements(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Announcements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray800,
              ),
            ),
            AppButton(
              variant: ButtonVariant.outline,
              onPressed: () =>
                  context.go(AppConstants.routeStudentAnnouncements),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_announcements.isEmpty)
          AppCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.notifications_none,
                  size: 48,
                  color: AppTheme.gray300,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No announcements yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray600,
                  ),
                ),
              ],
            ),
          )
        else
          ..._announcements.map((announcement) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6, right: 12),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              announcement.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.gray600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Helpers.formatDate(
                                  announcement.createdAt.toIso8601String()),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Gradient gradient;
  final Color bgColor;
  final Color textColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned(
            top: -64,
            right: -64,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
