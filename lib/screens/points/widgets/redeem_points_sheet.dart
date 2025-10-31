import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/points/controllers/points_controller.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/common/ui.dart';

class RedeemPointsSheet extends GetView<PointsController> {
  const RedeemPointsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSizes.lg),
          _buildPointsBalance(context),
          const SizedBox(height: AppSizes.lg),
          // _buildRedemptionOptions(context),
          // const SizedBox(height: AppSizes.lg),
          _buildWithdrawOption(context),
          const SizedBox(height: AppSizes.lg),

        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Redeem Points',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildPointsBalance(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.stars_outlined,
            color: context.theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Points',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Obx(() => Text(
                      '${controller.availablePoints.value}',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.primary,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redeem for Benefits',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Obx(() => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.redemptionOptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
              itemBuilder: (context, index) {
                final option = controller.redemptionOptions.entries.elementAt(index);
                return _buildRedemptionOption(context, option.key, option.value);
              },
            )),
      ],
    );
  }

  Widget _buildRedemptionOption(
    BuildContext context,
    String title,
    dynamic value,
  ) {
    final points = value['points'] as int;
    final description = value['description'] as String;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showRedemptionConfirmation(context, title, points),
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
                  color: context.theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getRedemptionIcon(title),
                  color: context.theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      description,
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
                  color: context.theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$points pts',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawOption(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showWithdrawConfirmation(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Withdraw to Wallet',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      'Convert points to wallet balance',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.green.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.green,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRedemptionIcon(String title) {
    switch (title.toLowerCase()) {
      case 'premium listing':
        return Icons.star_outline;
      case 'featured property':
        return Icons.home_outlined;
      case 'analytics upgrade':
        return Icons.analytics_outlined;
      case 'priority support':
        return Icons.support_agent_outlined;
      default:
        return Icons.card_giftcard_outlined;
    }
  }

  void _showRedemptionConfirmation(
    BuildContext context,
    String title,
    int points,
  ) {
    if (points > controller.availablePoints.value) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Insufficient points balance',
      ));
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('Confirm Redemption'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to redeem:'),
            const SizedBox(height: AppSizes.sm),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.sm),
            Text('Points required: $points'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.redeemPoints(
                points: points,
                redemptionType: title.toLowerCase().replaceAll(' ', '_'),
                additionalData: {
                  'activity_type': 'redeem',
                },
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void showWithdrawConfirmation(BuildContext context) {
    final points = controller.availablePoints.value;
    final amount = points * (controller.configService?.config.value?.payments.getPointsPerNaira ?? 100); // Assuming 100 points = $1

    if (points < (controller.configService?.config.value?.payments.getMinimumPointsForWithdrawal ?? 100)) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Minimum ${controller.configService?.config.value?.payments.getMinimumPointsForWithdrawal} points required for withdrawal',
      ));
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.green,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                'Confirm Withdrawal',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Points to Withdraw',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '$points pts',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),

                    
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Equivalent Amount',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '${Constant.currencySymbol} ${amount.toStringAsFixed(2)}',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              
              Text(
                          '1 Point = ${controller.configService?.config.value?.payments.getPointsPerNaira} Naira',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),

              const SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        controller.redeemPoints(
                          points: points,
                          redemptionType: 'withdraw',
                          additionalData: {
                            'activity_type': 'redeem',
                            'description': 'Withdraw to wallet',
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirm'),
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

  
} 