import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/error_handler.dart';
import '../../models/announcement.dart';
import '../../models/team.dart';
import '../../models/user.dart';
import '../../services/student_api.dart';
import '../../store/auth_store.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/app_sidebar.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  bool _isLoading = true;
  List<Team> _teams = [];
  List<Announcement> _announcements = [];
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authStore = Provider.of<AuthStore>(context, listen: false);
      _user = authStore.user;

      final teamsResponse = await StudentAPI.getMyTeams();
      final teams = teamsResponse
          .map((t) => Team.fromJson(t as Map<String, dynamic>))
          .toList();

      final announcementsResponse = await StudentAPI.getAnnouncements();
      final announcements = announcementsResponse
          .map((a) => Announcement.fromJson(a as Map<String, dynamic>))
          .toList();

      setState(() {
        _teams = teams;
        _announcements = announcements;
      });
    } catch (error) {
      // Use mock data on failure
      ErrorHandler.handleAPIError(error);

      final mockTeams = [
        Team(
          id: '1',
          teamName: 'Team Alpha',
          paymentStatus: 'PAID',
          status: 'STARTED',
          createdAt: DateTime.now(),
          members: const [],
        ),
        Team(
          id: '2',
          teamName: 'Team Beta',
          paymentStatus: 'UNPAID',
          createdAt: DateTime.now(),
          members: const [],
        ),
      ];

      final mockAnnouncements = [
        Announcement(
          id: '1',
          title: 'Welcome!',
          message: 'Registration is open',
          createdAt: DateTime.now(),
        ),
      ];

      setState(() {
        _teams = mockTeams;
        _announcements = mockAnnouncements;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

    final name = _user?.name ?? 'Student';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((p) => p[0]).take(2).join().toUpperCase()
        : 'S';

    final totalTeams = _teams.length;
    final paidTeams =
        _teams.where((t) => t.paymentStatus.toUpperCase() == 'PAID').length;
    final hackathonTeams =
        _teams.where((t) => t.hackathon != null).length;
    final announcementsCount = _announcements.length;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.gray900),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: AppTheme.gray900,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CircleAvatar(
              backgroundColor: AppTheme.primary100,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppTheme.primary700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
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
        userType: AppConstants.userTypeStudent,
        currentRoute: AppConstants.routeStudentDashboard,
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
                    colors: [
                      AppTheme.primary50,
                      AppTheme.secondary50,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, $name! 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ready to build something amazing?',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  _buildStatCard('Total Teams', totalTeams.toString()),
                  const SizedBox(width: 8),
                  _buildStatCard('Paid Teams', paidTeams.toString()),
                  const SizedBox(width: 8),
                  _buildStatCard('Hackathons', hackathonTeams.toString()),
                  const SizedBox(width: 8),
                  _buildStatCard('Announcements', announcementsCount.toString()),
                ],
              ),

              const SizedBox(height: 20),

              // My Teams header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Teams',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gray900,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.go(AppConstants.routeStudentMyTeams),
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: AppTheme.primary600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (_teams.isEmpty)
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.groups_outlined,
                        size: 48,
                        color: AppTheme.gray300,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No teams yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Create your first team to participate in hackathons.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.gray500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context
                            .go(AppConstants.routeStudentCreateTeam),
                        child: const Text(
                          'Create Team',
                          style: TextStyle(
                            color: AppTheme.primary600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _teams.take(3).map((team) {
                    final isPaid =
                        team.paymentStatus.toUpperCase() == 'PAID';
                    final membersCount = team.members?.length ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    team.teamName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.gray900,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPaid
                                        ? AppTheme.success50
                                        : AppTheme.warning50,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    isPaid ? 'PAID' : 'UNPAID',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isPaid
                                          ? AppTheme.success700
                                          : AppTheme.warning600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (team.hackathon != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.emoji_events_outlined,
                                    size: 16,
                                    color: AppTheme.gray500,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    team.hackathon!.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.gray600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$membersCount member${membersCount == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.gray600,
                                  ),
                                ),
                                if (!isPaid)
                                  TextButton(
                                    onPressed: () => context.go(
                                      '${AppConstants.routeStudentTeamPayment}/${team.id}',
                                    ),
                                    child: const Text(
                                      'Pay Now',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.primary600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),

              const Text(
                'Announcements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gray900,
                ),
              ),
              const SizedBox(height: 8),

              if (_announcements.isEmpty)
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.campaign_outlined,
                        size: 40,
                        color: AppTheme.gray300,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No announcements',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'You\'ll see important updates here.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _announcements.take(2).map((ann) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ann.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ann.message,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.gray600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Helpers.formatDate(
                                ann.createdAt.toIso8601String(),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.gray400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.go(AppConstants.routeStudentCreateTeam),
        backgroundColor: AppTheme.primary600,
        icon: const Icon(Icons.add),
        label: const Text('New Team'),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

