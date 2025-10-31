import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/points/controllers/points_controller.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/models/points/points_model.dart';

class PointsActivityList extends GetView<PointsController> {
  const PointsActivityList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.availableActivities.isEmpty
        ? _buildEmptyState(context)
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.availableActivities.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
            itemBuilder: (context, index) {
              final activity = controller.availableActivities[index];
              return _buildActivityTile(context, activity);
            },
          ));
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.xl),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars_outlined,
            size: 48,
            color: context.theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No Activities Available',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Check back later for new ways to earn points',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, PointsActivity activity) {
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
              color: context.theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getActivityIcon(activity.type),
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
                  activity.description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  _getActivitySubtitle(activity.type),
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
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${activity.points}',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(PointsActivityType type) {
    switch (type) {
      case PointsActivityType.profileCompletion:
        return Icons.person_outline;
      case PointsActivityType.dailyLogin:
        return Icons.login_outlined;
      case PointsActivityType.propertyListing:
        return Icons.home_outlined;
      case PointsActivityType.propertyView:
        return Icons.visibility_outlined;
      case PointsActivityType.referral:
        return Icons.people_outline;
      case PointsActivityType.referralPropertyListing:
        return Icons.home_work_outlined;
      case PointsActivityType.tourCompletion:
        return Icons.directions_walk_outlined;
      case PointsActivityType.reviewSubmission:
        return Icons.rate_review_outlined;
      case PointsActivityType.socialShare:
        return Icons.share_outlined;
    }
  }

  String _getActivitySubtitle(PointsActivityType type) {
    switch (type) {
      case PointsActivityType.profileCompletion:
        return 'Complete your profile to earn points';
      case PointsActivityType.dailyLogin:
        return 'Log in daily to earn points';
      case PointsActivityType.propertyListing:
        return 'List a property to earn points';
      case PointsActivityType.propertyView:
        return 'View properties to earn points';
      case PointsActivityType.referral:
        return 'Refer friends to earn points';
      case PointsActivityType.referralPropertyListing:
        return 'Earn points when referred users list properties';
      case PointsActivityType.tourCompletion:
        return 'Complete property tours to earn points';
      case PointsActivityType.reviewSubmission:
        return 'Submit reviews to earn points';
      case PointsActivityType.socialShare:
        return 'Share properties on social media to earn points';
    }
  }
} 