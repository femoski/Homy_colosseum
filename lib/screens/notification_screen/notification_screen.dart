import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:homy/models/users/notification.dart';
import 'package:homy/models/users/user_notification.dart';
import 'package:homy/screens/notification_screen/controllers/notification_controller.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/utils/user_image_custom.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      builder: (controller) {
        return Scaffold(
          appBar: _buildAppBar(controller),
          body: Column(
            children: [
              AuthHelper.isLoggedIn() ? _buildTabBar(controller) : const SizedBox(),
              Expanded(
                child: _buildNotificationList(controller),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(NotificationController controller) {
    return AppBar(
      title: const Text('Notifications'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          onPressed: controller.refreshNotification,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildTabBar(NotificationController controller) {
    final isDark = Get.isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabButton(
            label: 'Platform',
            isSelected: controller.selectedTab == 0,
            onTap: () => controller.onNotificationTabTap(0),
          ),
          _buildTabButton(
            label: 'For You',
            isSelected: controller.selectedTab == 1,
            onTap: () => controller.onNotificationTabTap(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Get.isDarkMode;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? Get.theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? Colors.grey.shade300
                      : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(NotificationController controller) {
    if (controller.isLoading) {
      return controller.selectedTab == 0
          ? _buildPlatformShimmer()
          : _buildForYouShimmer();
    }

    if (controller.selectedTab == 0
        ? controller.notifications.isEmpty
        : controller.userNotifications.isEmpty) {
      return _buildNoDataFound();
    }

    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: controller.selectedTab == 0
          ? controller.notifications.length
          : controller.userNotifications.length,
      itemBuilder: (context, index) {
        return controller.selectedTab == 0
            ? _PlatformNotificationCard(
                notification: controller.notifications[index])
            : _ForYouNotificationCard(
                notification: controller.userNotifications[index]);
      },
    );
  }

  Widget _buildNoDataFound() {
    final isDark = Get.isDarkMode;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 60,
              color: Get.theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: MyTextStyle.productMedium(
              size: 20,
              color: isDark ? Colors.grey.shade100 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any notifications yet',
            style: MyTextStyle.productLight(
              size: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForYouShimmer() {
    final isDark = Get.isDarkMode;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          ),
          color: isDark ? Colors.grey.shade900 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Shimmer.fromColors(
              baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              highlightColor:
                  isDark ? Colors.grey.shade700 : Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 16,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade800 : Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 14,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey.shade800 : Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlatformShimmer() {
    final isDark = Get.isDarkMode;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          ),
          color: isDark ? Colors.grey.shade900 : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              highlightColor:
                  isDark ? Colors.grey.shade700 : Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade800 : Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ForYouNotificationCard extends StatelessWidget {
  final NotificationData notification;

  const _ForYouNotificationCard({required this.notification});

  void _showDetailsDialog(BuildContext context) {
    final isDark = Get.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    UserImageCustom(
                      image: (notification.title ?? ''),
                      name: notification.title ?? 'Unknown',
                      widthHeight: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification.title ?? 'Unknown',
                        style: MyTextStyle.productMedium(
                          size: 16,
                          color: isDark ? Colors.grey.shade100 : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.description ?? '',
                          style: MyTextStyle.productLight(
                            size: 15,
                            color: isDark ? Colors.grey.shade300 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${notification.createdAt}',
                              style: MyTextStyle.productLight(
                                size: 12,
                                color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                              ),
                            ),
                            if (notification.isRead ?? false)
                              Row(
                                children: [
                                  Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 16,
                                    color: Get.theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Viewed',
                                    style: MyTextStyle.productLight(
                                      size: 12,
                                      color: Get.theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: InkWell(
        onTap: () => _showDetailsDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserImageCustom(
                    image: (notification.title ?? ''),
                    name: notification.title ?? 'Unknown',
                    widthHeight: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notification.title ?? 'Unknown',
                      style: MyTextStyle.productMedium(
                        size: 14,
                        color: isDark ? Colors.grey.shade100 : Get.theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.description ?? '',
                style: MyTextStyle.productLight(
                  size: 13,
                  color: isDark ? Colors.grey.shade300 : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${notification.createdAt}',
                    style: MyTextStyle.productLight(
                      size: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                    ),
                  ),
                  if (notification.isRead ?? false)
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 16,
                      color: Get.theme.colorScheme.primary,
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

class _PlatformNotificationCard extends StatelessWidget {
  final NotificationData notification;

  const _PlatformNotificationCard({required this.notification});

  void _showDetailsDialog(BuildContext context) {
    final isDark = Get.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Get.theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: Get.theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        notification.title ?? '',
                        style: MyTextStyle.productMedium(
                          size: 16,
                          color: isDark ? Colors.grey.shade100 : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.description ?? '',
                          style: MyTextStyle.productLight(
                            size: 15,
                            color: isDark ? Colors.grey.shade300 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${notification.createdAt}',
                              style: MyTextStyle.productLight(
                                size: 12,
                                color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                              ),
                            ),
                            if (notification.isRead ?? false)
                              Row(
                                children: [
                                  Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 16,
                                    color: Get.theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Viewed',
                                    style: MyTextStyle.productLight(
                                      size: 12,
                                      color: Get.theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: InkWell(
        onTap: () => _showDetailsDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: Get.theme.colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notification.title ?? '',
                      style: MyTextStyle.productMedium(
                        size: 14,
                        color: isDark ? Colors.grey.shade100 : Get.theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.description ?? '',
                style: MyTextStyle.productLight(
                  size: 13,
                  color: isDark ? Colors.grey.shade300 : Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${notification.createdAt}',
                    style: MyTextStyle.productLight(
                      size: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                    ),
                  ),
                  if (notification.isRead ?? false)
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 16,
                      color: Get.theme.colorScheme.primary,
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

