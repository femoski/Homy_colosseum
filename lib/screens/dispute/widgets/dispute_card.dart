import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/dispute/dispute_model.dart';
import 'package:intl/intl.dart';

class DisputeCard extends StatelessWidget {
  final Dispute dispute;
  final VoidCallback onTap;

  const DisputeCard({
    Key? key,
    required this.dispute,
    required this.onTap,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (dispute.status) {
      case '0':
        return Colors.orange;
      case '1':
        return Colors.green;
      case '2': 
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (dispute.status) {
      case '0':
        return 'Pending';
      case '1':
        return 'Resolved for Agent';
      case '2':
        return 'Resolved for User';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Get.theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dispute.property?.name ?? '',
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Reason: ${dispute.reason}',
                style: Get.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filed by: ${dispute.participants?.initiatedBy?.name}',
                    style: Get.textTheme.bodySmall,
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(dispute?.createdAt ?? DateTime.now()),
                    style: Get.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 