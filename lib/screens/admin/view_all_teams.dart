import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils/error_handler.dart';
import '../../services/admin_api.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/empty_state.dart';

class AdminViewAllTeamsScreen extends StatefulWidget {
  const AdminViewAllTeamsScreen({super.key});

  @override
  State<AdminViewAllTeamsScreen> createState() =>
      _AdminViewAllTeamsScreenState();
}

class _AdminViewAllTeamsScreenState extends State<AdminViewAllTeamsScreen> {
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
      final filters = _filter != 'ALL' ? {'payment_status': _filter} : null;
      final data = await AdminAPI.getTeams(filters: filters);
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
      final name = (map['team_name'] ?? '').toString().toLowerCase();
      return q.isEmpty || name.contains(q);
    }).toList();
  }

  int get _totalTeams => _teams.length;
  int get _paidTeams => _teams
      .where((t) =>
          (t['payment_status'] ?? '').toString().toUpperCase() == 'PAID')
      .length;
  int get _unpaidTeams => _totalTeams - _paidTeams;

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _filter = value;
          });
          _loadTeams();
        },
        selectedColor: AppTheme.primary600,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.gray700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppTheme.primary600 : AppTheme.gray300,
          width: isSelected ? 0 : 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTeams = _filteredTeams;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Teams (Admin)'),
            Text(
              '$_totalTeams teams',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeAdminDashboard),
        ),
      ),
      body: _isLoading
          ? const AppLoader()
          : Column(
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
                // Stats bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.gray100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$_totalTeams total',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success50,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$_paidTeams paid',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.success700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warning50,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$_unpaidTeams unpaid',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.warning600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Teams list
                Expanded(
                  child: filteredTeams.isEmpty
                      ? const EmptyState(
                          icon: Icons.groups_outlined,
                          message: 'No data found',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredTeams.length,
                          itemBuilder: (context, index) {
                            final map = filteredTeams[index]
                                as Map<String, dynamic>;
                            final teamName =
                                (map['team_name'] ?? '').toString();
                            final collegeName =
                                (map['college_name'] ?? '').toString();
                            final departmentName =
                                (map['department_name'] ?? '').toString();
                            final hackathonName =
                                (map['hackathon']?['name'] ?? '').toString();
                            final topicName =
                                (map['topic']?['name'] ?? '').toString();
                            final status = (map['payment_status'] ?? 'UNPAID')
                                .toString()
                                .toUpperCase();
                            final members = (map['members'] as List?) ?? [];
                            final githubUrl = map['github_url']?.toString();

                            final isPaid = status == 'PAID';

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 16,
                              ),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isPaid
                                                  ? AppTheme.success50
                                                  : AppTheme.warning50,
                                              borderRadius:
                                                  BorderRadius.circular(999),
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
                                      if (collegeName.isNotEmpty)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.account_balance_outlined,
                                              size: 14,
                                              color: AppTheme.gray500,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              collegeName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppTheme.gray600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (departmentName.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.apartment_outlined,
                                              size: 14,
                                              color: AppTheme.gray500,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              departmentName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppTheme.gray600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (hackathonName.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.emoji_events_outlined,
                                              size: 14,
                                              color: AppTheme.gray500,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                hackathonName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppTheme.gray600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (topicName.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.label_outline,
                                              size: 14,
                                              color: AppTheme.gray500,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                topicName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppTheme.gray600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.people_outline,
                                            size: 14,
                                            color: AppTheme.gray500,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Members: ${members.length}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.gray600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (githubUrl != null &&
                                          githubUrl.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.link,
                                              size: 14,
                                              color: AppTheme.gray500,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                githubUrl,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme.primary600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
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
