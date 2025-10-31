import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/notifications/controller/notifications_controller.dart';
import 'package:homy/models/notifications/notification_model.dart';
import 'package:homy/screens/notifications/widgets/notification_card.dart';
import 'package:homy/screens/notifications/widgets/notification_detail_bottom_sheet.dart';
import 'package:homy/screens/notifications/widgets/notifications_empty_state.dart';
import 'package:homy/screens/notifications/widgets/notifications_loading_state.dart';
import 'package:homy/utils/my_text_style.dart';

class NotificationsPage extends GetView<NotificationsController> {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Obx(() => _buildBody(context)),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final isDark = Get.isDarkMode;
    
    return AppBar(
      title: Text(
        'Notifications',
        style: MyTextStyle.productMedium(
          size: 20,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: isDark ? Colors.white : Colors.black87,
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() => controller.unreadCount > 0
            ? Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.unreadCount}',
                  style: MyTextStyle.productMedium(
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              )
            : const SizedBox()),
        PopupMenuButton<String>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.grey[800],
          
          icon: Icon(
            Icons.more_vert,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mark_all_read',
              child: Row(
                children: [
                  Icon(Icons.done_all),
                  SizedBox(width: 8),
                  Text('Mark All Read'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_all',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 8),
                  Text('Clear All'),
                ],
              ),
            ),
          ],
        ),
      ],
      // backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      elevation: 0,
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading && controller.allNotifications.isEmpty) {
      return const NotificationsLoadingState();
    }

    if (controller.error.isNotEmpty) {
      return _buildErrorState(context);
    }

    if (controller.allNotifications.isEmpty) {
      return const NotificationsEmptyState();
    }

    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      child: ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: controller.allNotifications.length + 
                   (controller.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= controller.allNotifications.length) {
            return _buildLoadingIndicator();
          }

          final notification = controller.allNotifications[index];
          return SwipeableNotificationCard(
            notification: notification,
            onTap: () => {
              _showNotificationDetail(context, notification),
               controller.markAsRead(notification),
            },
            onMarkAsRead: () => controller.markAsRead(notification),
            onMarkAsUnread: () => controller.markAsUnread(notification),
            onDelete: () => controller.deleteNotification(notification),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final isDark = Get.isDarkMode;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: MyTextStyle.productMedium(
              size: 18,
              color: isDark ? Colors.grey.shade300 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.error,
            style: MyTextStyle.productLight(
              size: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.refreshNotifications,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _showNotificationDetail(BuildContext context, NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationDetailBottomSheet(
        notification: notification,
        onMarkAsRead: () =>  controller.markAsRead(notification),
        onDelete: () => controller.deleteNotification(notification),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'mark_all_read':
        controller.markAllAsRead();
        break;
      case 'clear_all':
        controller.clearAllNotifications();
        break;
    }
  }
}
