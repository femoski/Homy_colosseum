import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/my_text_style.dart';

class TourRequestStats {
  final int waiting;
  final int upcoming;

  const TourRequestStats({
    required this.waiting,
    required this.upcoming,
  });
}

class TourRequestsSection extends StatelessWidget {
  final TourRequestStats receivedRequests;
  final TourRequestStats submittedRequests;

  const TourRequestsSection({
    super.key,
    required this.receivedRequests,
    required this.submittedRequests,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRequestSection(
          context,
          title: 'Tour Requests Received',
          stats: receivedRequests,
          type: 0,
        ),
        const SizedBox(height: 24),
        _buildRequestSection(
          context,
          title: 'Tour Requests Submitted',
          stats: submittedRequests,
          type: 1,
        ),
      ],
    );
  }

  Widget _buildRequestSection(
    BuildContext context, {
    required String title,
    required TourRequestStats stats,
    required int type,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MyTextStyle.productBold(
            size: 20,
            color: context.theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RequestCard(
                value: stats.waiting,
                label: 'Waiting',
                onTap: () => _navigateToTourRequests(type, 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RequestCard(
                value: stats.upcoming,
                label: 'Upcoming',
                onTap: () => _navigateToTourRequests(type, 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToTourRequests(int type, int tab) {
    final routes = {
      0: {
        0: '/tour-requests/received/waiting',
        1: '/tour-requests/received/upcoming',
      },
      1: {
        0: '/tour-requests/submitted/waiting',
        1: '/tour-requests/submitted/upcoming',
      },
    };

    Get.toNamed(
      routes[type]?[tab] ?? '',
      arguments: {'type': type, 'tab': tab},
    );
  }
}

class _RequestCard extends StatelessWidget {
  final int value;
  final String label;
  final VoidCallback onTap;

  const _RequestCard({
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.theme.colorScheme.outline.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: MyTextStyle.productBold(
                size: 28,
                color: context.theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
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