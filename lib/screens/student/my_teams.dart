import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../models/team.dart';
import '../../../models/hackathon.dart';
import '../../../models/topic.dart';
import '../../../models/member.dart';
import '../../../services/student_api.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_loader.dart';
import '../../../widgets/common/empty_state.dart';

class MyTeamsScreen extends StatefulWidget {
  const MyTeamsScreen({super.key});

  @override
  State<MyTeamsScreen> createState() => _MyTeamsScreenState();
}

class _MyTeamsScreenState extends State<MyTeamsScreen> {
  bool _isLoading = true;
  List<Team> _teams = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() => _isLoading = true);

    try {
      final data = await StudentAPI.getMyTeams();
      final teams = data
          .map((t) => Team.fromJson(t as Map<String, dynamic>))
          .toList();

      setState(() {
        _teams = teams;
      });
    } catch (error) {
      // Use mock data on failure (same structure as dashboard mock)
      ErrorHandler.handleAPIError(error);

      final mockTeams = [
        Team(
          id: '1',
          teamName: 'Team Alpha',
          paymentStatus: 'PAID',
          status: 'STARTED',
          createdAt: DateTime.now(),
          hackathon: Hackathon(
            id: 'h1',
            name: 'AI Challenge',
            description: '',
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            teamFee: 0,
            maxTeamSize: 5,
            status: 'ACTIVE',
          ),
          topic: Topic(
            id: 't1',
            name: 'Computer Vision',
          ),
          members: [
            Member(id: 'm1', name: 'You', email: 'you@example.com'),
            Member(id: 'm2', name: 'Alice', email: 'alice@example.com'),
          ],
        ),
        Team(
          id: '2',
          teamName: 'Team Beta',
          paymentStatus: 'UNPAID',
          createdAt: DateTime.now(),
          members: [
            Member(id: 'm3', name: 'You', email: 'you@example.com'),
          ],
        ),
      ];

      setState(() {
        _teams = mockTeams;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Team> get _filteredTeams {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _teams;
    return _teams
        .where(
          (t) => t.teamName.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _showAddGithubDialog(Team team) async {
    final controller = TextEditingController(text: team.githubUrl ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add GitHub Repository'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'GitHub URL',
              hintText: 'https://github.com/username/repo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final url = controller.text.trim();
                if (url.isEmpty) {
                  ErrorHandler.showError('Please enter a valid URL');
                  return;
                }
                try {
                  await StudentAPI.updateTeam(team.id, {
                    'github_url': url,
                  });
                  ErrorHandler.showSuccess('GitHub link updated');
                  if (mounted) {
                    Navigator.of(context).pop();
                    _loadTeams();
                  }
                } catch (error) {
                  ErrorHandler.handleAPIError(error);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMembersSheet(Team team) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final members = team.members ?? [];
        final nameController = TextEditingController();
        final emailController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Team Members (${members.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (members.isEmpty)
                const Text(
                  'No members added yet.',
                  style: TextStyle(color: AppTheme.gray600),
                )
              else
                ...members.map(
                  (m) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(
                        m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                      ),
                    ),
                    title: Text(m.name),
                    subtitle: Text(m.email),
                  ),
                ),
              const Divider(height: 24),
              const Text(
                'Add Member',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    if (name.isEmpty || email.isEmpty) {
                      ErrorHandler.showError('Please enter name and email');
                      return;
                    }
                    try {
                      await StudentAPI.addTeamMember(team.id, {
                        'name': name,
                        'email': email,
                      });
                      ErrorHandler.showSuccess('Member added');
                      if (mounted) {
                        Navigator.of(context).pop();
                        _loadTeams();
                      }
                    } catch (error) {
                      ErrorHandler.handleAPIError(error);
                    }
                  },
                  child: const Text('Add Member'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _truncateUrl(String url, {int maxLength = 30}) {
    if (url.length <= maxLength) return url;
    return '${url.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoader();
    }

    final teams = _filteredTeams;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('My Teams'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeStudentDashboard),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
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
          ),
          Expanded(
            child: teams.isEmpty
                ? EmptyState(
                    icon: Icons.groups_outlined,
                    message: 'No data found',
                    actionLabel: 'Create Team',
                    onAction: () => context.go(AppConstants.routeStudentCreateTeam),
                  )
                : ListView.builder(
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final isPaid =
                          team.paymentStatus.toUpperCase() == 'PAID';
                      final hasHackathon = team.hackathon != null;
                      final hasTopic = team.topic != null;
                      final hasGithub =
                          (team.githubUrl != null && team.githubUrl!.isNotEmpty);
                      final membersCount = team.members?.length ?? 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
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
                              const SizedBox(height: 8),
                              if (hasHackathon)
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
                              if (hasTopic)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.label_outline,
                                        size: 16,
                                        color: AppTheme.gray500,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        team.topic!.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.gray600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (membersCount > 0) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Members: $membersCount',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.gray600,
                                  ),
                                ),
                              ],
                              if (hasGithub) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.link,
                                      size: 16,
                                      color: AppTheme.primary600,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _truncateUrl(team.githubUrl!),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.primary600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!isPaid && hasHackathon)
                                    AppButton(
                                      onPressed: () => context.go(
                                        '${AppConstants.routeStudentTeamPayment}/${team.id}',
                                      ),
                                      child: const Text('Pay Now'),
                                    ),
                                  if (isPaid && !hasGithub)
                                    AppButton(
                                      variant: ButtonVariant.outline,
                                      onPressed: () => _showAddGithubDialog(team),
                                      child: const Text('Add GitHub'),
                                    ),
                                  AppButton(
                                    variant: ButtonVariant.secondary,
                                    onPressed: () => _showMembersSheet(team),
                                    child: const Text('Members'),
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
        ],
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
}












