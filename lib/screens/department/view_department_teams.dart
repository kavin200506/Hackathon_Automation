import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../services/department_api.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_loader.dart';
import '../../../widgets/common/empty_state.dart';

class ViewDepartmentTeamsScreen extends StatefulWidget {
  const ViewDepartmentTeamsScreen({super.key});

  @override
  State<ViewDepartmentTeamsScreen> createState() =>
      _ViewDepartmentTeamsScreenState();
}

class _ViewDepartmentTeamsScreenState extends State<ViewDepartmentTeamsScreen> {
  bool _isLoading = true;
  List<dynamic> _teams = [];
  List<dynamic> _hackathons = [];
  String _filter = 'ALL';
  String _hackathonFilter = 'ALL';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final teams = await DepartmentAPI.getTeams();
      setState(() {
        _teams = teams;
        // Extract unique hackathons from teams
        final hackathonSet = <String>{};
        for (final team in teams) {
          final map = team as Map<String, dynamic>;
          final hackathonName = (map['hackathon']?['name'] ?? '').toString();
          if (hackathonName.isNotEmpty) {
            hackathonSet.add(hackathonName);
          }
        }
        _hackathons = hackathonSet.map((name) => {'name': name}).toList();
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
            'topic': {'name': 'Machine Learning'},
            'members': [
              {'name': 'John Doe', 'email': 'john@example.com'},
              {'name': 'Jane Smith', 'email': 'jane@example.com'},
            ],
          },
          {
            'id': 'team-2',
            'team_name': 'Team Beta',
            'leader_name': 'Alice Johnson',
            'payment_status': 'UNPAID',
            'hackathon': {'name': 'Tech Innovation'},
            'topic': {'name': 'Web Development'},
            'members': [
              {'name': 'Alice Johnson', 'email': 'alice@example.com'},
            ],
          },
          {
            'id': 'team-3',
            'team_name': 'Team Gamma',
            'leader_name': 'Bob Wilson',
            'payment_status': 'PAID',
            'hackathon': {'name': 'AI Challenge'},
            'topic': {'name': 'Deep Learning'},
            'members': [
              {'name': 'Bob Wilson', 'email': 'bob@example.com'},
              {'name': 'Carol Brown', 'email': 'carol@example.com'},
            ],
          },
        ];
        _hackathons = [
          {'name': 'AI Challenge'},
          {'name': 'Tech Innovation'},
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
      final hackathonName = (map['hackathon']?['name'] ?? '').toString();

      final matchesStatusFilter = _filter == 'ALL' || status == _filter;
      final matchesHackathonFilter =
          _hackathonFilter == 'ALL' || hackathonName == _hackathonFilter;
      final matchesSearch = q.isEmpty || name.contains(q);

      return matchesStatusFilter && matchesHackathonFilter && matchesSearch;
    }).toList();
  }

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

  Widget _buildHackathonFilterChip(String label, String value) {
    final isSelected = _hackathonFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _hackathonFilter = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Department Teams')),
        body: const AppLoader(),
      );
    }

    final teams = _filteredTeams;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Department Teams'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeDepartmentDashboard),
        ),
      ),
      body: Column(
        children: [
          // Filter bars
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildFilterChip('All', 'ALL'),
                    _buildFilterChip('Paid', 'PAID'),
                    _buildFilterChip('Unpaid', 'UNPAID'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildHackathonFilterChip('All Hackathons', 'ALL'),
                    ..._hackathons.map((h) {
                      final name = h['name'].toString();
                      return _buildHackathonFilterChip(name, name);
                    }),
                  ],
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                ? const EmptyState(
                    icon: Icons.groups_outlined,
                    message: 'No data found',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      return _buildTeamCard(teams[index] as Map<String, dynamic>);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> map) {
    final teamName = (map['team_name'] ?? '').toString();
    final leaderName = (map['leader_name'] ?? '').toString();
    final hackathonName = (map['hackathon']?['name'] ?? '').toString();
    final topicName = (map['topic']?['name'] ?? '').toString();
    final status = (map['payment_status'] ?? 'UNPAID').toString().toUpperCase();
    final members = (map['members'] as List?) ?? [];

    final isPaid = status == 'PAID';

    return _TeamCardWidget(
      teamName: teamName,
      leaderName: leaderName,
      hackathonName: hackathonName,
      topicName: topicName,
      status: status,
      isPaid: isPaid,
      members: members,
    );
  }
}

class _TeamCardWidget extends StatefulWidget {
  final String teamName;
  final String leaderName;
  final String hackathonName;
  final String topicName;
  final String status;
  final bool isPaid;
  final List<dynamic> members;

  const _TeamCardWidget({
    required this.teamName,
    required this.leaderName,
    required this.hackathonName,
    required this.topicName,
    required this.status,
    required this.isPaid,
    required this.members,
  });

  @override
  State<_TeamCardWidget> createState() => _TeamCardWidgetState();
}

class _TeamCardWidgetState extends State<_TeamCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                  widget.teamName,
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
                  color: widget.isPaid
                      ? AppTheme.success50
                      : AppTheme.warning50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  widget.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: widget.isPaid
                        ? AppTheme.success700
                        : AppTheme.warning600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Leader: ${widget.leaderName}',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.gray600,
            ),
          ),
          if (widget.hackathonName.isNotEmpty) ...[
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
                  widget.hackathonName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.gray600,
                  ),
                ),
              ],
            ),
          ],
          if (widget.topicName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.label_outline,
                  size: 16,
                  color: AppTheme.gray500,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.topicName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.gray600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  'Members: ${widget.members.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.gray600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppTheme.gray500,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            ...widget.members.map((member) {
              final name = (member['name'] ?? '').toString();
              final email = (member['email'] ?? '').toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppTheme.gray500,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.gray800,
                            ),
                          ),
                          if (email.isNotEmpty)
                            Text(
                              email,
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
              );
            }),
          ],
          ],
        ),
      ),
    );
  }
}
