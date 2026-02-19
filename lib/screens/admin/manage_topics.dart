import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils/error_handler.dart';
import '../../services/admin_api.dart';
import '../../services/hackathon_api.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_input.dart';

class ManageTopicsScreen extends StatefulWidget {
  const ManageTopicsScreen({super.key});

  @override
  State<ManageTopicsScreen> createState() => _ManageTopicsScreenState();
}

class _ManageTopicsScreenState extends State<ManageTopicsScreen> {
  bool _isLoadingHackathons = true;
  bool _isLoadingTopics = false;
  bool _isAddingTopic = false;

  List<dynamic> _hackathons = [];
  List<dynamic> _topics = [];
  String? _selectedHackathonId;
  final TextEditingController _topicNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHackathons();
  }

  @override
  void dispose() {
    _topicNameController.dispose();
    super.dispose();
  }

  Future<void> _loadHackathons() async {
    setState(() => _isLoadingHackathons = true);
    try {
      final data = await AdminAPI.getHackathons();
      setState(() {
        _hackathons = data;
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);
      setState(() {
        _hackathons = [];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingHackathons = false);
      }
    }
  }

  Future<void> _loadTopicsForHackathon(String hackathonId) async {
    setState(() {
      _isLoadingTopics = true;
      _topics = [];
    });
    try {
      final data = await HackathonAPI.getTopics(hackathonId);
      setState(() {
        _topics = data;
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);
      setState(() {
        _topics = [];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingTopics = false);
      }
    }
  }

  Future<void> _handleAddTopic() async {
    if (_selectedHackathonId == null) {
      ErrorHandler.showError('Please select a hackathon first');
      return;
    }
    final name = _topicNameController.text.trim();
    if (name.isEmpty) {
      ErrorHandler.showError('Please enter a topic name');
      return;
    }

    setState(() => _isAddingTopic = true);
    try {
      await AdminAPI.createTopic({
        'hackathon_id': _selectedHackathonId,
        'name': name,
      });
      _topicNameController.clear();
      await _loadTopicsForHackathon(_selectedHackathonId!);
      ErrorHandler.showSuccess('Topic added');
    } catch (error) {
      ErrorHandler.handleAPIError(error);
    } finally {
      if (mounted) {
        setState(() => _isAddingTopic = false);
      }
    }
  }

  Future<void> _handleDeleteTopic(Map<String, dynamic> topic) async {
    // If a delete endpoint exists, call it here. For now, show not implemented.
    ErrorHandler.showError('Delete topic is not implemented yet in Flutter client.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Manage Topics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeAdminDashboard),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Hackathon',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _isLoadingHackathons
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          value: _selectedHackathonId,
                          decoration: InputDecoration(
                            hintText: 'Select a hackathon',
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
                          items: _hackathons.map((h) {
                            final map = h as Map<String, dynamic>;
                            final id = map['id']?.toString() ?? '';
                            final name = (map['name'] ?? '').toString();
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedHackathonId = value;
                            });
                            if (value != null) {
                              _loadTopicsForHackathon(value);
                            } else {
                              setState(() {
                                _topics = [];
                              });
                            }
                          },
                        ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedHackathonId != null) ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Topics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingTopics
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _topics.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'No topics added yet.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.gray500,
                                  ),
                                ),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _topics.map((t) {
                                  final topic =
                                      t as Map<String, dynamic>;
                                  final name =
                                      (topic['name'] ?? '').toString();
                                  return Chip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(name),
                                        const SizedBox(width: 4),
                                        InkWell(
                                          onTap: () => _handleDeleteTopic(topic),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            size: 18,
                                            color: AppTheme.error600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppTheme.gray100,
                                  );
                                }).toList(),
                              ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'Add New Topic',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AppInput(
                            hintText: 'Topic Name',
                            controller: _topicNameController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        AppButton(
                          isLoading: _isAddingTopic,
                          onPressed: _handleAddTopic,
                          child: const Text('Add Topic'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Select a hackathon to view and manage topics.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.gray500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}











