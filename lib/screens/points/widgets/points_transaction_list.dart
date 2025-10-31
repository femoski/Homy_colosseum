import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/points/controllers/points_controller.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/helpers/helper_utils.dart';
import 'package:homy/models/points/points_model.dart';
import 'package:shimmer/shimmer.dart';

class PointsTransactionList extends GetView<PointsController> {
  const PointsTransactionList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // _buildTimeFrameFilter(context),
        // const SizedBox(height: AppSizes.md),
        Obx(() {
          if (controller.isLoading.value) {
            return _buildShimmerLoading(context);
          } else if (controller.transactions.isEmpty) {
            return _buildEmptyState(context);
          } else {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
              itemBuilder: (context, index) {
                final transaction = controller.transactions[index];
                return _buildTransactionTile(context, transaction);
              },
            );
          }
        }),
      ],
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6, // Show 6 shimmer items while loading
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, index) {
        return _buildShimmerTransactionTile(context);
      },
    );
  }

  Widget _buildShimmerTransactionTile(BuildContext context) {
    // Determine shimmer colors based on theme
    final isDark = context.theme.brightness == Brightness.dark;
    final baseColor = isDark 
        ? Colors.grey[800]! 
        : Colors.grey[300]!;
    final highlightColor = isDark 
        ? Colors.grey[700]! 
        : Colors.grey[100]!;
    final shimmerColor = isDark 
        ? Colors.grey[600]! 
        : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Row(
          children: [
            // Shimmer for the icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: shimmerColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shimmer for the description text
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  // Shimmer for the time text
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            // Shimmer for the points badge
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFrameFilter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTimeFrameChip(context, 'all', 'All'),
            _buildTimeFrameChip(context, 'today', 'Today'),
            _buildTimeFrameChip(context, 'week', 'This Week'),
            _buildTimeFrameChip(context, 'month', 'This Month'),
            _buildTimeFrameChip(context, 'year', 'This Year'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFrameChip(BuildContext context, String value, String label) {
    final isSelected = controller.selectedTimeFrame.value == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.sm),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          if (selected) {
            controller.setTimeFrame(value);
          }
        },
        backgroundColor: context.theme.colorScheme.surface,
        selectedColor: context.theme.colorScheme.primary.withOpacity(0.2),
        checkmarkColor: context.theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? context.theme.colorScheme.primary
              : context.theme.colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? context.theme.colorScheme.primary
                : context.theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.theme.colorScheme.surface.withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_outlined,
            size: 48,
            color: context.theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No Transactions Yet',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Your points history will appear here',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, PointsTransaction transaction) {
    final isEarned = transaction.type == 'earned';
    final color = isEarned ? Colors.green : context.theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        // border: Border.all(
        //   color: context.theme.colorScheme.outline.withOpacity(0.5),
        // ),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarned ? Icons.add_circle_outline : Icons.remove_circle_outline,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  HelperUtils.timeAgo(transaction.createdAt.millisecondsSinceEpoch),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${isEarned ? '+' : '-'}${transaction.points}',
              style: context.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 