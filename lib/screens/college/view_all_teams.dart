import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../services/college_api.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_loader.dart';
import '../../../widgets/common/empty_state.dart';

class ViewAllTeamsScreen extends StatefulWidget {
  const ViewAllTeamsScreen({super.key});

  @override
  State<ViewAllTeamsScreen> createState() => _ViewAllTeamsScreenState();
}

class _ViewAllTeamsScreenState extends State<ViewAllTeamsScreen> {
  bool _isLoading = true;
  List<dynamic> _teams = [];
  String _filter = 'ALL';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() => _isLoading = true);
    try {
      final data = await CollegeAPI.getTeams();
      setState(() {
        _teams = data;
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);
      setState(() {
        _teams = [];
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
      return const AppLoader();
    }

    final teams = _filteredTeams;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('All Teams'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeCollegeDashboard),
        ),
      ),
      body: Column(
        children: [
          // Filter bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 'ALL'),
                _buildFilterChip('Paid', 'PAID'),
                _buildFilterChip('Unpaid', 'UNPAID'),
                _buildFilterChip('Pending', 'PENDING'),
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
                      final map = teams[index] as Map<String, dynamic>;
                      final teamName = (map['team_name'] ?? '').toString();
                      final deptName =
                          (map['department_name'] ?? 'Department: -')
                              .toString();
                      final hackathonName = (map['hackathon']?['name'] ?? '')
                          .toString();
                      final status = (map['payment_status'] ?? 'UNPAID')
                          .toString()
                          .toUpperCase();
                      final members = (map['members'] as List?) ?? [];

                      final isPaid = status == 'PAID';

                      return AppCard(
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
                              deptName,
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
