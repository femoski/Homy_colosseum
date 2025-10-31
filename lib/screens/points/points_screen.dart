import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/points/controllers/points_controller.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/screens/points/widgets/points_transaction_list.dart';
import 'package:homy/screens/points/widgets/points_activity_list.dart';

import 'widgets/redeem_points_sheet.dart';

class PointsScreen extends GetView<PointsController> {
  const PointsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Points & Rewards',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<PointsController>(
        builder: (controller) => RefreshIndicator(
          onRefresh: controller.refreshPoints,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Column(
              children: [
                _buildPointsCard(context),
                const SizedBox(height: AppSizes.xl),
                _buildActionButtons(context),
                const SizedBox(height: AppSizes.xl),
                _buildPointsHistory(context),
                const SizedBox(height: AppSizes.xl),
                // _buildAvailableActivities(context),
                // const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.theme.colorScheme.primary,
            context.theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.stars_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Points',
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Obx(() => Text(
                    '${controller.totalPoints.value}',
                    style: context.textTheme.displaySmall?.copyWith(
                      fontFamily: 'Roboto',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  )),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child:  Text(
                          'Available to Redeem',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: AppSizes.sm,
                  //     vertical: AppSizes.xs,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white.withOpacity(0.2),
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  //   child: Obx(() => Text(
                  //         '${controller.pendingPoints.value} Pending',
                  //         style: context.textTheme.bodySmall?.copyWith(
                  //           color: Colors.white,
                  //         ),
                  //       )),
                  // ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildModernActionButton(
            context,
            icon: Icons.card_giftcard_outlined,
            label: 'Redeem Points',
            onTap: () => RedeemPointsSheet().showWithdrawConfirmation(context),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _buildModernActionButton(
            context,
            icon: Icons.people_outline,
            label: 'Refer & Earn',
            onTap: controller.showReferralSheet,
            color: context.theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.lg,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Points History',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              onPressed: () => Get.toNamed('/all-points'),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                foregroundColor: context.theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        const PointsTransactionList(),
      ],
    );
  }

  Widget _buildAvailableActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earn More Points',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        const PointsActivityList(),
      ],
    );
  }
} 