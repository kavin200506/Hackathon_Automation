import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils/error_handler.dart';
import '../../core/utils/validators.dart';
import '../../services/admin_api.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_input.dart';

class CreateHackathonScreen extends StatefulWidget {
  const CreateHackathonScreen({super.key});

  @override
  State<CreateHackathonScreen> createState() => _CreateHackathonScreenState();
}

class _CreateHackathonScreenState extends State<CreateHackathonScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _maxTeamSizeController =
      TextEditingController(text: '5');

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _feeController.dispose();
    _maxTeamSizeController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final base = _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? base,
      firstDate: base,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null) {
      ErrorHandler.showError('Please select a start date');
      return;
    }
    if (_endDate == null) {
      ErrorHandler.showError('Please select an end date');
      return;
    }

    final fee = double.tryParse(_feeController.text.trim());
    if (fee == null) {
      ErrorHandler.showError('Please enter a valid registration fee');
      return;
    }

    final maxTeamSize = int.tryParse(_maxTeamSizeController.text.trim());
    if (maxTeamSize == null || maxTeamSize <= 0) {
      ErrorHandler.showError('Please enter a valid max team size');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await AdminAPI.createHackathon({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'start_date': _startDate!.toIso8601String(),
        'end_date': _endDate!.toIso8601String(),
        'team_fee': fee,
        'max_team_size': maxTeamSize,
      });

      ErrorHandler.showSuccess('Hackathon created!');
      if (!mounted) return;
      context.go(AppConstants.routeAdminManageTopics);
    } catch (error) {
      ErrorHandler.handleAPIError(error);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Create Hackathon'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeAdminDashboard),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AppCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create Hackathon',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set up a new hackathon event and configure basic details.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppInput(
                      label: 'Hackathon Name',
                      hintText: 'Enter hackathon name',
                      controller: _nameController,
                      validator: (value) =>
                          Validators.validateRequired(value, fieldName: 'Hackathon name'),
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      label: 'Description',
                      hintText: 'Short description about this hackathon',
                      controller: _descriptionController,
                      maxLines: 4,
                      validator: (value) =>
                          Validators.validateRequired(value, fieldName: 'Description'),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickStartDate,
                            child: AbsorbPointer(
                              child: AppInput(
                                label: 'Start Date',
                                hintText: 'Select start date',
                                controller: TextEditingController(
                                  text: _startDate != null
                                      ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
                                      : '',
                                ),
                                suffixIcon: const Icon(Icons.calendar_today_outlined),
                                validator: (value) {
                                  if (_startDate == null) {
                                    return 'Please select a start date';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickEndDate,
                            child: AbsorbPointer(
                              child: AppInput(
                                label: 'End Date',
                                hintText: 'Select end date',
                                controller: TextEditingController(
                                  text: _endDate != null
                                      ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
                                      : '',
                                ),
                                suffixIcon: const Icon(Icons.calendar_today_outlined),
                                validator: (value) {
                                  if (_endDate == null) {
                                    return 'Please select an end date';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: AppInput(
                            label: 'Registration Fee (₹)',
                            hintText: 'e.g., 500',
                            controller: _feeController,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                Validators.validateRequired(value, fieldName: 'Registration fee'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppInput(
                            label: 'Max Team Size',
                            hintText: 'e.g., 5',
                            controller: _maxTeamSizeController,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                Validators.validateRequired(value, fieldName: 'Max team size'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      isFullWidth: true,
                      isLoading: _isSubmitting,
                      onPressed: _handleSubmit,
                      child: const Text(
                        'Create Hackathon',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}











