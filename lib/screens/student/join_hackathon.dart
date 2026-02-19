import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/hackathon.dart';
import '../../../models/team.dart';
import '../../../models/topic.dart';
import '../../../services/hackathon_api.dart';
import '../../../services/student_api.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_loader.dart';

class JoinHackathonScreen extends StatefulWidget {
  const JoinHackathonScreen({super.key});

  @override
  State<JoinHackathonScreen> createState() => _JoinHackathonScreenState();
}

class _JoinHackathonScreenState extends State<JoinHackathonScreen> {
  bool _isLoading = true;
  List<Hackathon> _hackathons = [];
  List<Topic> _topics = [];
  List<Team> _teams = [];
  String? _selectedHackathonId;
  String? _selectedTopicId;
  String? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      // Load active hackathons
      final hacksData = await HackathonAPI.getActiveHackathons();
      final hacks = hacksData
          .map((h) => Hackathon.fromJson(h as Map<String, dynamic>))
          .toList();

      // Load teams and filter to those not in a hackathon yet
      final teamsData = await StudentAPI.getMyTeams();
      final teams = teamsData
          .map((t) => Team.fromJson(t as Map<String, dynamic>))
          .where((t) => t.hackathon == null)
          .toList();

      setState(() {
        _hackathons = hacks;
        _teams = teams;
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadTopicsForHackathon(String hackathonId) async {
    setState(() {
      _topics = [];
      _selectedTopicId = null;
    });

    try {
      final topicsData = await HackathonAPI.getTopics(hackathonId);
      final topics = topicsData
          .map((t) => Topic.fromJson(t as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _topics = topics;
        });
      }
    } catch (error) {
      ErrorHandler.handleAPIError(error);
    }
  }

  Future<void> _handleJoin() async {
    if (_selectedTeamId == null ||
        _selectedHackathonId == null ||
        _selectedTopicId == null) {
      ErrorHandler.showError(
        'Please select your team, hackathon and topic before proceeding.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await StudentAPI.joinHackathon(
        _selectedTeamId!,
        _selectedHackathonId!,
        _selectedTopicId!,
      );

      if (!mounted) return;
      ErrorHandler.showSuccess('Team registered for hackathon!');
      context.go(AppConstants.routeStudentMyTeams);
    } catch (error) {
      ErrorHandler.handleAPIError(error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoader();
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Join Hackathon'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeStudentDashboard),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.event_available_rounded,
                      size: 56,
                      color: AppTheme.primary600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Join a Hackathon',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Select your team, hackathon and topic',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 1. Select Team
                  const Text(
                    '1. Select Your Team',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTeamId,
                    items: _teams.map((team) {
                      final isPaid =
                          team.paymentStatus.toUpperCase() == 'PAID';
                      return DropdownMenuItem<String>(
                        value: team.id,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(team.teamName),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
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
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      hintText: _teams.isEmpty
                          ? 'No eligible teams available'
                          : 'Select your team',
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _teams.isEmpty
                        ? null
                        : (value) {
                            setState(() {
                              _selectedTeamId = value;
                            });
                          },
                  ),

                  const SizedBox(height: 20),

                  // 2. Select Hackathon
                  const Text(
                    '2. Select Hackathon',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedHackathonId,
                    items: _hackathons.map((hack) {
                      final dateRange =
                          '${Helpers.formatDate(hack.startDate.toIso8601String())} - '
                          '${Helpers.formatDate(hack.endDate.toIso8601String())}';
                      return DropdownMenuItem<String>(
                        value: hack.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hack.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateRange,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.gray600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      hintText: _hackathons.isEmpty
                          ? 'No active hackathons available'
                          : 'Select hackathon',
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _hackathons.isEmpty
                        ? null
                        : (value) {
                            setState(() {
                              _selectedHackathonId = value;
                              _selectedTopicId = null;
                            });
                            if (value != null) {
                              _loadTopicsForHackathon(value);
                            }
                          },
                  ),

                  const SizedBox(height: 20),

                  // 3. Select Topic
                  const Text(
                    '3. Select Topic',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTopicId,
                    items: _topics.map((topic) {
                      return DropdownMenuItem<String>(
                        value: topic.id,
                        child: Text(topic.name),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      hintText: _selectedHackathonId == null
                          ? 'Select hackathon first'
                          : (_topics.isEmpty
                              ? 'No topics available'
                              : 'Select topic'),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_selectedHackathonId == null || _topics.isEmpty)
                        ? null
                        : (value) {
                            setState(() {
                              _selectedTopicId = value;
                            });
                          },
                  ),

                  const SizedBox(height: 28),

                  AppButton(
                    isFullWidth: true,
                    isLoading: _isLoading,
                    onPressed: _handleJoin,
                    child: const Text(
                      'Register Team for Hackathon',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      '⚠️ Payment required after joining',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
}












