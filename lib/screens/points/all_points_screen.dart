import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/points/controllers/points_controller.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/models/points/points_model.dart';
import 'package:homy/utils/helpers/helper_utils.dart';

class AllPointsScreen extends GetView<PointsController> {
  const AllPointsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

      controller.fetchTransactions(); 
    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Points History',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTimeFrameFilter(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchTransactions(refresh: true),
              child: Obx(() {
                if (controller.isLoading.value && controller.allTransactions.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.allTransactions.isEmpty) {
                  return _buildEmptyState(context);
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo is ScrollEndNotification) {
                      if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8) {
                        controller.fetchTransactions();
                      }
                    }
                    return true;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    itemCount: controller.allTransactions.length + (controller.hasMorePages.value ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
                    itemBuilder: (context, index) {
                      if (index == controller.allTransactions.length) {
                        if (controller.hasMorePages.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSizes.md),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }
                      return _buildTransactionTile(context, controller.allTransactions[index]);
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFrameFilter(BuildContext context) {
    return Container(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: context.theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            'No Transactions Yet',
            style: context.textTheme.titleLarge?.copyWith(
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
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.5),
        ),
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
          Text(
            '${isEarned ? '+' : '-'}${transaction.points}',
            style: context.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}