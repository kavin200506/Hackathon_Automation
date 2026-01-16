import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/team.dart';
import '../common/app_card.dart';
import '../common/app_button.dart';
import '../../core/utils/helpers.dart';

class TeamCardWidget extends StatelessWidget {
  final Team team;
  final VoidCallback? onUpdate;

  const TeamCardWidget({
    super.key,
    required this.team,
    this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      enableHover: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.teamName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created ${Helpers.formatDate(team.createdAt.toIso8601String())}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: team.paymentStatus == 'PAID'
                      ? AppTheme.success100
                      : AppTheme.warning100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  team.paymentStatus == 'PAID' ? 'Paid' : 'Unpaid',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: team.paymentStatus == 'PAID'
                        ? AppTheme.success700
                        : AppTheme.warning600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (team.hackathon != null) ...[
            _InfoRow(
              icon: Icons.emoji_events,
              iconColor: AppTheme.primary600,
              label: 'Hackathon:',
              value: team.hackathon!.name,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.topic,
              iconColor: AppTheme.secondary600,
              label: 'Topic:',
              value: team.topic?.name ?? 'Not selected',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.currency_rupee,
              iconColor: AppTheme.success600,
              label: 'Fee:',
              value: '₹${team.hackathon!.teamFee.toInt()}',
            ),
            const SizedBox(height: 8),
          ],
          _InfoRow(
            icon: Icons.people,
            iconColor: AppTheme.warning600,
            label: 'Members:',
            value: '${team.members?.length ?? 0}/5',
          ),
          if (team.githubUrl != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.code, size: 16, color: AppTheme.gray600),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Open GitHub URL
                    },
                    child: Text(
                      'View Repository',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primary600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (team.members != null && team.members!.isNotEmpty) ...[
            const Divider(height: 32),
            const Text(
              'Team Members:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray700,
              ),
            ),
            const SizedBox(height: 8),
            ...team.members!.map((member) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.gray50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.gray800,
                              ),
                            ),
                            Text(
                              member.email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (team.paymentStatus == 'UNPAID')
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          color: AppTheme.error600,
                          onPressed: () {
                            // Handle remove member
                          },
                        ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (team.paymentStatus == 'UNPAID' &&
                  (team.members?.length ?? 0) < 5)
                AppButton(
                  variant: ButtonVariant.outline,
                  onPressed: () {
                    // Handle add member
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add, size: 16),
                      SizedBox(width: 4),
                      Text('Add Member'),
                    ],
                  ),
                ),
              if (team.hackathon != null && team.paymentStatus == 'UNPAID')
                AppButton(
                  onPressed: () {
                    context.go('${AppConstants.routeStudentTeamPayment}/${team.id}');
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.payment, size: 16),
                      SizedBox(width: 4),
                      Text('Make Payment'),
                    ],
                  ),
                ),
              if (team.paymentStatus == 'PAID')
                AppButton(
                  variant: ButtonVariant.outline,
                  onPressed: () {
                    // Handle GitHub URL
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.code, size: 16),
                      const SizedBox(width: 4),
                      Text(team.githubUrl != null ? 'Update' : 'Add'),
                      const SizedBox(width: 4),
                      const Text('GitHub URL'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.gray600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.gray600,
            ),
          ),
        ),
      ],
    );
  }
}

