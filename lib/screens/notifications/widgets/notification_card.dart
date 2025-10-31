import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/notifications/notification_model.dart';
import 'package:homy/utils/my_text_style.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(isDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: MyTextStyle.productRegular(
                                  size: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: notification.isRead 
                                      ? FontWeight.normal 
                                      : FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.shortMessage,
                      style: MyTextStyle.productLight(
                        size: 14,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.timeAgo,
                          style: MyTextStyle.productLight(
                            size: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        if (notification.isRead)
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Get.theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.notifications_active_rounded,
        color: Get.theme.colorScheme.primary,
        size: 20,
      ),
    );
  }
}

class SwipeableNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onMarkAsUnread;
  final VoidCallback? onDelete;

  const SwipeableNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onMarkAsUnread,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right to mark as read/unread
          if (notification.isRead) {
            onMarkAsUnread?.call();
          } else {
            onMarkAsRead?.call();
          }
          return false; // Don't dismiss the item
        } else if (direction == DismissDirection.endToStart) {
          // Swipe left to delete
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      background: _buildSwipeBackground(
        context,
        isLeft: true,
        icon: notification.isRead ? Icons.mark_email_unread : Icons.mark_email_read,
        color: notification.isRead ? Colors.orange : Colors.green,
        label: notification.isRead ? 'Mark Unread' : 'Mark Read',
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        isLeft: false,
        icon: Icons.delete_outline,
        color: Colors.red,
        label: 'Delete',
      ),
      child: NotificationCard(
        notification: notification,
        onTap: onTap,
        onMarkAsRead: onMarkAsRead,
        onDelete: onDelete,
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required bool isLeft,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLeft) ...[
            Text(
              label,
              style: MyTextStyle.productMedium(
                size: 14,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          if (isLeft) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: MyTextStyle.productMedium(
                size: 14,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete?.call();
              Get.back(result: true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
