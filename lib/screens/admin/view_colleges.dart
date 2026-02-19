import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils/error_handler.dart';
import '../../models/college.dart';
import '../../services/admin_api.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/empty_state.dart';

class ViewCollegesScreen extends StatefulWidget {
  const ViewCollegesScreen({super.key});

  @override
  State<ViewCollegesScreen> createState() => _ViewCollegesScreenState();
}

class _ViewCollegesScreenState extends State<ViewCollegesScreen> {
  bool _isLoading = true;
  List<College> _colleges = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadColleges();
  }

  Future<void> _loadColleges() async {
    setState(() => _isLoading = true);
    try {
      final data = await AdminAPI.getColleges();
      setState(() {
        _colleges = data.map<College>((c) => College.fromJson(c)).toList();
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);
      setState(() {
        _colleges = [];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<College> get _filteredColleges {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _colleges;
    return _colleges.where((c) {
      final name = c.name.toLowerCase();
      final email = c.email.toLowerCase();
      final addr = (c.address ?? '').toLowerCase();
      return name.contains(q) || email.contains(q) || addr.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Colleges'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeAdminDashboard),
        ),
      ),
      body: _isLoading
          ? const AppLoader()
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search colleges...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppTheme.gray300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppTheme.gray300),
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
                  child: _filteredColleges.isEmpty
                      ? const EmptyState(
                          icon: Icons.account_balance_outlined,
                          message: 'No data found',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredColleges.length,
                          itemBuilder: (context, index) {
                            final college = _filteredColleges[index];
                            final departments =
                                college.departmentCount ?? 0;
                            final teams = college.teamCount ?? 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AppCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Text(
                                    college.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.gray900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    college.email,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.gray600,
                                    ),
                                  ),
                                  if (college.address != null &&
                                      college.address!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      college.address!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.gray500,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary50,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '$departments Departments',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.primary700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.secondary50,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '$teams Teams',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.secondary700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (college.tpoName != null &&
                                      college.tpoName!.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'TPO: ${college.tpoName}',
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
                          },
                        ),
                ),
              ],
            ),
    );
  }
}











