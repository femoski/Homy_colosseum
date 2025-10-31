import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:homy/screens/points/controllers/points_controller.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/common/ui.dart';
import 'package:share_plus/share_plus.dart';

class ReferralSheet extends GetView<PointsController> {
  const ReferralSheet({Key? key}) : super(key: key);

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
          _buildReferralInfo(context),
          const SizedBox(height: AppSizes.lg),
          _buildReferralBenefits(context),
          const SizedBox(height: AppSizes.lg),
          _buildShareButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Refer & Earn',
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

  Widget _buildReferralInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Referral Code',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context.theme.colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        controller.referralCode.value,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: controller.referralCode.value),
                      );
                      Get.showSnackbar(CommonUI.SuccessSnackBar(
                        message: 'Referral code copied to clipboard',
                      ));
                    },
                    icon: const Icon(Icons.copy_outlined),
                  ),
                ],
              )),
          const SizedBox(height: AppSizes.md),
          Text(
            'Share your referral code with friends and earn points when they sign up and complete actions!',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralBenefits(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How it Works',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        _buildBenefitItem(
          context,
          'Share your code',
          'Share your unique referral code with friends',
          Icons.share_outlined,
        ),
        const SizedBox(height: AppSizes.sm),
        _buildBenefitItem(
          context,
          'Friends sign up',
          'Your friends sign up using your referral code',
          Icons.person_add_outlined,
        ),
        const SizedBox(height: AppSizes.sm),
        _buildBenefitItem(
          context,
          'Earn points',
          'Earn points when your friends complete actions',
          Icons.stars_outlined,
        ),
      ],
    );
  }

  Widget _buildBenefitItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
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
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShareButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _shareReferralLink(context),
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share Link'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareReferralCode(context),
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy Code'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            ),
          ),
        ),
      ],
    );
  }

  void _shareReferralLink(BuildContext context) {
    final referralLink = 'https://urlink.com/app/register?ref=${controller.referralCode.value}';
    Share.share(
      'Join Homy using my referral code: ${controller.referralCode.value}\n$referralLink',
      subject: 'Join Homy with my referral code',
    );
  }

  void _shareReferralCode(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: controller.referralCode.value),
    );
    Get.showSnackbar(CommonUI.SuccessSnackBar(
      message: 'Referral code copied to clipboard',
    ));
  }
} 