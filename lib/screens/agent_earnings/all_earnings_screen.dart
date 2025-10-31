import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/agent_earnings/controllers/earnings_controller.dart';
import 'package:homy/models/earning.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:intl/intl.dart';

class AllEarningsScreen extends GetView<EarningsController> {
  const AllEarningsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'All Earnings',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: GetBuilder<EarningsController>(
        builder: (controller) => Column(
          children: [
            _buildFilterChips(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshEarnings,
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  itemCount: controller.earnings.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
                  itemBuilder: (context, index) {
                    if (index == controller.earnings.length) {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (controller.hasMore.value) {
                        controller.loadMoreEarnings();
                        return const Center(child: CircularProgressIndicator());
                      }
                      return const SizedBox.shrink();
                    }
                    final earning = controller.earnings[index];
                    return _buildEarningItem(context, earning);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return GetBuilder<EarningsController>(
      builder: (controller) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
        child: Row(
          children: [
            if (controller.selectedTimeFrame.value != '')
              Chip(
                label: Text(controller.selectedTimeFrame.value),
                onDeleted: () => controller.clearTimeFrame(),
                deleteIcon: const Icon(Icons.close, size: 18),
              ),
            const SizedBox(width: AppSizes.sm),
            if (controller.selectedStatus.value != '')
              Chip(
                label: Text(controller.selectedStatus.value),
                onDeleted: () => controller.clearStatus(),
                deleteIcon: const Icon(Icons.close, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningItem(BuildContext context, Earning earning) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor.withOpacity(0.05),
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
              color: context.theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.attach_money_rounded,
              color: context.theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  earning.tourTime,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(earning.tourDate),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.theme.colorScheme.onSurface.withOpacity(0.5),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${Constant.currencySymbol}${earning.agentEarning.toStringAsFixed(2)}',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                earning.status,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.theme.colorScheme.primary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Earnings',
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),
              _buildTimeFrameFilter(context),
              const SizedBox(height: AppSizes.xl),
              _buildStatusFilter(context),
              const SizedBox(height: AppSizes.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.clearTimeFrame();
                      controller.clearStatus();
                      controller.applyFilters();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg,
                        vertical: AppSizes.sm,
                      ),
                    ),
                    child: Text(
                      'Clear All',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  FilledButton(
                    onPressed: () {
                      controller.applyFilters();
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg,
                        vertical: AppSizes.sm,
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFrameFilter(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
          'Time Frame',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: [
            'Today',
            'This Week',
            'This Month',
            'Last Month',
            'This Year',
          ].map((timeFrame) {
            final isSelected = controller.selectedTimeFrame.value == timeFrame;
            return FilterChip(
              label: Text(
                timeFrame,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? context.theme.colorScheme.onPrimary
                      : context.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  controller.setTimeFrame(timeFrame);
                } else {
                  controller.clearTimeFrame();
                }
              },
              backgroundColor: context.theme.colorScheme.surface,
              selectedColor: context.theme.colorScheme.primary,
              checkmarkColor: context.theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.outline.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              showCheckmark: true,
              elevation: isSelected ? 2 : 0,
              shadowColor: context.theme.colorScheme.shadow.withOpacity(0.1),
            );
          }).toList(),
        ),
        ],
      );
    });
  }

  Widget _buildStatusFilter(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          'Status',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Wrap(
          spacing: AppSizes.sm,
          runSpacing: AppSizes.sm,
          children: [
            'Pending',
            'Completed',
            'Processing',
            'Failed',
          ].map((status) {
            final isSelected = controller.selectedStatus.value == status;
            return FilterChip(
              label: Text(
                status,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? context.theme.colorScheme.onPrimary
                      : context.theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  controller.setStatus(status);
                } else {
                  controller.clearStatus();
                }
              },
              backgroundColor: context.theme.colorScheme.surface,
              selectedColor: context.theme.colorScheme.primary,
              checkmarkColor: context.theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? context.theme.colorScheme.primary
                      : context.theme.colorScheme.outline.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              showCheckmark: true,
              elevation: isSelected ? 2 : 0,
              shadowColor: context.theme.colorScheme.shadow.withOpacity(0.1),
            );
          }).toList(),
        ),
        ],
      );
    });
  }
} 