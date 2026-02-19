import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils/error_handler.dart';
import '../../services/admin_api.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_loader.dart';
import '../../widgets/common/empty_state.dart';

class ManageAnnouncementsScreen extends StatefulWidget {
  const ManageAnnouncementsScreen({super.key});

  @override
  State<ManageAnnouncementsScreen> createState() =>
      _ManageAnnouncementsScreenState();
}

class _ManageAnnouncementsScreenState
    extends State<ManageAnnouncementsScreen> {
  bool _isLoading = true;
  List<dynamic> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    try {
      final data = await AdminAPI.getAnnouncements();
      setState(() {
        _announcements = data;
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);
      setState(() {
        _announcements = [];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openCreateDialog() async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String targetType = 'ALL';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppInput(
                  label: 'Title',
                  hintText: 'Enter announcement title',
                  controller: titleController,
                ),
                const SizedBox(height: 12),
                AppInput(
                  label: 'Message',
                  hintText: 'Write the announcement message',
                  controller: messageController,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Target',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.gray700,
                  ),
                ),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setInnerState) {
                    return DropdownButtonFormField<String>(
                      value: targetType,
                      items: const [
                        DropdownMenuItem(
                          value: 'ALL',
                          child: Text('All Students'),
                        ),
                        DropdownMenuItem(
                          value: 'HACKATHON',
                          child: Text('Specific Hackathon'),
                        ),
                        DropdownMenuItem(
                          value: 'TOPIC',
                          child: Text('Specific Topic'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setInnerState(() {
                          targetType = value;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            AppButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final message = messageController.text.trim();
                if (title.isEmpty || message.isEmpty) {
                  ErrorHandler.showError(
                    'Please enter both title and message',
                  );
                  return;
                }
                try {
                  await AdminAPI.createAnnouncement({
                    'title': title,
                    'message': message,
                    'target_type': targetType,
                  });
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ErrorHandler.showSuccess('Announcement created');
                  await _loadAnnouncements();
                } catch (error) {
                  ErrorHandler.handleAPIError(error);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDelete(Map<String, dynamic> announcement) async {
    // If delete endpoint exists in AdminAPI, call it; otherwise show not implemented.
    ErrorHandler.showError(
      'Delete announcement is not implemented yet in Flutter client.',
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Announcements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeAdminDashboard),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        backgroundColor: AppTheme.primary600,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const AppLoader()
          : _announcements.isEmpty
              ? const EmptyState(
                  icon: Icons.campaign_outlined,
                  message: 'No data found',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _announcements.length,
                  itemBuilder: (context, index) {
                    final map = _announcements[index] as Map<String, dynamic>;
                    final title = (map['title'] ?? '').toString();
                    final message = (map['message'] ?? '').toString();
                    final createdAt =
                        _formatDate(map['created_at']?.toString());

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
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.gray900,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: AppTheme.primary600,
                                    ),
                                    onPressed: () {
                                      ErrorHandler.showError(
                                        'Edit announcement is not implemented yet.',
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: AppTheme.error600,
                                    ),
                                    onPressed: () => _handleDelete(map),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (createdAt.isNotEmpty)
                            Text(
                              createdAt,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.gray500,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.gray700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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











