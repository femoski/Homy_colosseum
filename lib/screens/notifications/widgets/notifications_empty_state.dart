import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/notifications/controller/notifications_controller.dart';
import 'package:homy/utils/my_text_style.dart';

class NotificationsEmptyState extends GetView<NotificationsController> {
  const NotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'You don\'t have any notifications yet.\nWe\'ll notify you when something important happens!',
              style: MyTextStyle.productLight(
                size: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: controller.refreshNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
