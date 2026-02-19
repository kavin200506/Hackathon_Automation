import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/error_handler.dart';
import '../../../services/student_api.dart';
import '../../../widgets/common/app_loader.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
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
      final data = await StudentAPI.getAnnouncements();
      setState(() {
        _announcements = data;
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);

      // Mock fallback
      final now = DateTime.now();
      setState(() {
        _announcements = [
          {
            'title': 'Welcome!',
            'message': 'Registration is open for the upcoming hackathon.',
            'created_at': now.toIso8601String(),
            'hackathon_name': 'Cathon 2026',
          },
          {
            'title': 'Team Formation Tips',
            'message': 'Form diverse teams with different skill sets.',
            'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
            'topic_name': 'Best Practices',
          },
          {
            'title': 'Submission Deadline',
            'message': 'Final project submissions are due by Sunday 8 PM.',
            'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
          },
        ];
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
        title: const Text('Announcements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeStudentDashboard),
        ),
      ),
      body: _announcements.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.campaign_outlined,
                    size: 56,
                    color: AppTheme.gray300,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No announcements',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.gray500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _announcements.length,
              itemBuilder: (context, index) {
                final ann = _announcements[index] as Map<String, dynamic>;
                final title = ann['title']?.toString() ?? '';
                final message = ann['message']?.toString() ?? '';
                final createdAt = ann['created_at']?.toString() ?? '';
                final hackathonName = ann['hackathon_name']?.toString();
                final topicName = ann['topic_name']?.toString();

                final dateText = createdAt.isNotEmpty
                    ? Helpers.formatDate(createdAt)
                    : '';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.gray800,
                                ),
                              ),
                            ),
                            if (dateText.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.gray100,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  dateText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.gray600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.gray600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (hackathonName != null || topicName != null)
                          Row(
                            children: [
                              if (hackathonName != null && hackathonName.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary50,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    hackathonName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.primary700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              if (topicName != null && topicName.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondary50,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    topicName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.secondary700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
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












