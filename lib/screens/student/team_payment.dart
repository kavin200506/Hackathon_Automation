import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/team.dart';
import '../../../services/payment_api.dart';
import '../../../services/student_api.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/app_input.dart';
import '../../../widgets/common/app_loader.dart';

class TeamPaymentScreen extends StatefulWidget {
  final String teamId;

  const TeamPaymentScreen({
    super.key,
    required this.teamId,
  });

  @override
  State<TeamPaymentScreen> createState() => _TeamPaymentScreenState();
}

class _TeamPaymentScreenState extends State<TeamPaymentScreen> {
  bool _isLoading = true;
  bool _isApplyingCoupon = false;
  Team? _team;
  double _amount = 0;
  double _discountedAmount = 0;
  final TextEditingController _couponController = TextEditingController();
  String? _couponMessage;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _loadTeam() async {
    setState(() => _isLoading = true);
    try {
      final data = await StudentAPI.getMyTeams();
      final teams = data
          .map((t) => Team.fromJson(t as Map<String, dynamic>))
          .toList();

      final team = teams.firstWhere(
        (t) => t.id == widget.teamId,
        orElse: () => throw Exception('Team not found'),
      );

      final fee = team.hackathon?.teamFee ?? 0;

      setState(() {
        _team = team;
        _amount = fee;
        _discountedAmount = fee;
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);
      if (mounted) {
        context.go(AppConstants.routeStudentMyTeams);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty || _amount <= 0) return;

    setState(() {
      _isApplyingCoupon = true;
      _couponMessage = null;
    });

    try {
      final response = await PaymentAPI.applyCoupon(code, _amount);
      final rawFinal = response['final_amount'] ?? response['discounted_amount'];
      final finalAmount =
          rawFinal is num ? rawFinal.toDouble() : _amount;

      final saved = _amount - finalAmount;

      setState(() {
        _discountedAmount = finalAmount;
        _couponMessage = saved > 0
            ? 'Coupon applied! Saved ${Helpers.formatCurrency(saved)}'
            : 'Coupon applied.';
      });
    } catch (error) {
      ErrorHandler.handleAPIError(error);
      setState(() {
        _couponMessage = null;
        _discountedAmount = _amount;
      });
    } finally {
      if (mounted) {
        setState(() => _isApplyingCoupon = false);
      }
    }
  }

  Future<void> _handlePayment() async {
    if (_team == null || _discountedAmount <= 0) return;

    setState(() => _isLoading = true);

    try {
      await PaymentAPI.createPaymentOrder({
        'team_id': _team!.id,
        'amount': _discountedAmount,
      });

      if (!mounted) return;
      ErrorHandler.showSuccess(
        'Payment of ${Helpers.formatCurrency(_discountedAmount)} successful! Team status updated to PAID',
      );
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
    if (_isLoading || _team == null) {
      return const AppLoader();
    }

    final team = _team!;
    final hackathon = team.hackathon;
    final topic = team.topic;
    final membersCount = team.members?.length ?? 0;

    final originalAmountText = Helpers.formatCurrency(_amount);
    final discountedText = Helpers.formatCurrency(_discountedAmount);
    final discount = _amount - _discountedAmount;
    final hasDiscount = discount > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Team Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppConstants.routeStudentMyTeams),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team details card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.teamName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gray900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (hackathon != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.emoji_events_outlined,
                              size: 16,
                              color: AppTheme.gray500,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              hackathon.name,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.gray600,
                              ),
                            ),
                          ],
                        ),
                      if (topic != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.label_outline,
                                size: 16,
                                color: AppTheme.gray500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                topic.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (membersCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.people_alt_outlined,
                                size: 16,
                                color: AppTheme.gray500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Members: $membersCount',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Registration Fee',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.gray600,
                            ),
                          ),
                          Text(
                            originalAmountText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Coupon card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Have a coupon?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              hintText: 'Enter coupon code',
                              controller: _couponController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            onPressed:
                                _isApplyingCoupon ? null : () => _applyCoupon(),
                            isLoading: _isApplyingCoupon,
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                      if (_couponMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _couponMessage!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.success600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Payment summary
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Original Amount',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.gray600,
                            ),
                          ),
                          Text(
                            originalAmountText,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.gray800,
                            ),
                          ),
                        ],
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Discount',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.success700,
                              ),
                            ),
                            Text(
                              '-${Helpers.formatCurrency(discount)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.success700,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Payable',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.gray900,
                            ),
                          ),
                          Text(
                            discountedText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                AppButton(
                  isFullWidth: true,
                  isLoading: _isLoading,
                  variant: ButtonVariant.success,
                  onPressed: _handlePayment,
                  child: Text(
                    'Pay $discountedText Now',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: AppTheme.gray400,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Secured payment',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}












