import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/my_text_style.dart';

class ProfileStatsSection extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final List<StatItem> stats;

  const ProfileStatsSection({
    super.key,
    required this.title,
    required this.onSeeAll,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        _buildStatsGrid(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: MyTextStyle.productBold(
            size: 20,
            color: context.theme.colorScheme.onBackground,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'See All',
            style: MyTextStyle.productMedium(
              size: 14,
              color: context.theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: stat == stats.last ? 0 : 12,
            ),
            child: _StatCard(stat: stat),
          ),
        );
      }).toList(),
    );
  }
}

class StatItem {
  final int value;
  final String label;
  final VoidCallback onTap;

  const StatItem({
    required this.value,
    required this.label,
    required this.onTap,
  });
}

class _StatCard extends StatelessWidget {
  final StatItem stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: stat.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${stat.value}',
              style: MyTextStyle.productBold(
                size: 28,
                color: context.theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.label,
              style: MyTextStyle.productMedium(
                size: 14,
                color: context.theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 