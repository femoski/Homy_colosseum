import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/agent_earnings/controllers/earnings_controller.dart';
import 'package:homy/screens/agent_earnings/all_earnings_screen.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:intl/intl.dart';

class EarningsScreen extends GetView<EarningsController> {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'My Earnings',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<EarningsController>(
        builder: (controller) => RefreshIndicator(
          onRefresh: controller.refreshEarnings,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Column(
              children: [
                _buildTotalEarningsCard(context),
                const SizedBox(height: AppSizes.xl),
                _buildEarningsList(context),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalEarningsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.attach_money_rounded,
                  color: context.theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Total Earnings',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.theme.colorScheme.onSurface.withOpacity(0.7),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            '${Constant.currencySymbol}${controller.totalEarnings.toStringAsFixed(2)}',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'All processed earnings',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.onSurface.withOpacity(0.5),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: context.theme.shadowColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Earnings History',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => const AllEarningsScreen());
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'View All',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          if (controller.isLoading.value)
            const Center(child: CircularProgressIndicator())
          else if (controller.earnings.isEmpty)
            _buildEmptyEarnings(context)
          else
            _buildEarningsListView(context),
        ],
      ),
    );
  }

  Widget _buildEmptyEarnings(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.money_off_rounded,
              size: 48,
              color: context.theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No earnings yet',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.theme.colorScheme.onSurface.withOpacity(0.7),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsListView(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.earnings.length,
      separatorBuilder: (_, __) => Divider(
        color: context.theme.colorScheme.outline.withOpacity(0.1),
        height: AppSizes.lg,
      ),
      itemBuilder: (context, index) {
        final earning = controller.earnings[index];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
      },
    );
  }
} 