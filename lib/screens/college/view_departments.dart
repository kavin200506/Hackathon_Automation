import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../services/college_api.dart';
import '../../../widgets/common/app_loader.dart';
import '../../../widgets/common/empty_state.dart';

class ViewDepartmentsScreen extends StatefulWidget {
  const ViewDepartmentsScreen({super.key});

  @override
  State<ViewDepartmentsScreen> createState() => _ViewDepartmentsScreenState();
}

class _ViewDepartmentsScreenState extends State<ViewDepartmentsScreen> {
  bool _isLoading = true;
  List<dynamic> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() => _isLoading = true);
    try {
      final data = await CollegeAPI.getDepartments();
      setState(() {
        _departments = data;
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);
      setState(() {
        _departments = [];
      });
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
        title: const Text('Departments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeCollegeDashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                context.go(AppConstants.routeCollegeCreateDepartment),
          ),
        ],
      ),
      body: _departments.isEmpty
          ? EmptyState(
              icon: Icons.apartment_outlined,
              message: 'No data found',
              actionLabel: 'Create Department',
              onAction: () =>
                  context.go(AppConstants.routeCollegeCreateDepartment),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _departments.length,
              itemBuilder: (context, index) {
                final dept = _departments[index] as Map<String, dynamic>;
                final name = dept['name']?.toString() ?? '';
                final hodName = dept['hod_name']?.toString() ?? 'Not assigned';
                final email = dept['hod_email']?.toString() ?? '-';
                final teamCount = dept['team_count'] ?? 0;
                final status = (dept['status'] ?? 'ACTIVE')
                    .toString()
                    .toUpperCase();

                final isActive = status == 'ACTIVE';

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
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
                                  color: AppTheme.gray800,
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
                                isActive ? 'Active' : status,
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
                          'HOD: $hodName',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.gray600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.gray500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Teams: $teamCount',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
