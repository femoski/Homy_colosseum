import 'package:get_storage/get_storage.dart';
import 'package:homy/models/notifications/notification_model.dart';

class NotificationStorageService {
  static const String _allNotificationsKey = 'all_notifications';
  static const String _lastRefreshTimeKey = 'last_notification_refresh';
  static const String _readNotificationsKey = 'read_notifications';
  static const String _deletedNotificationsKey = 'deleted_notifications';
  static const String _unreadCountKey = 'unread_count';

  final GetStorage _storage = GetStorage();

  /// Save all notifications
  Future<void> saveAllNotifications(List<NotificationModel> notifications) async {
    final List<Map<String, dynamic>> serializedList = 
        notifications.map((notification) => notification.toJson()).toList();
    await _storage.write(_allNotificationsKey, serializedList);
  }

  /// Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    final List<dynamic>? data = _storage.read(_allNotificationsKey);
    if (data == null) return [];
    return data.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Save last refresh time
  Future<void> saveLastRefreshTime() async {
    await _storage.write(_lastRefreshTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Check if should refresh from server
  bool shouldRefreshFromServer() {
    final lastRefresh = _storage.read<int>(_lastRefreshTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Refresh every 30 seconds
    return now - lastRefresh >  30 * 1000;
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    final List<int> readNotifications = 
        List<int>.from(_storage.read(_readNotificationsKey) ?? []);
    
    if (!readNotifications.contains(notificationId)) {
      readNotifications.add(notificationId);
      await _storage.write(_readNotificationsKey, readNotifications);
    }
  }

  /// Check if notification is read
  bool isRead(int notificationId) {
    final List<int> readNotifications = 
        List<int>.from(_storage.read(_readNotificationsKey) ?? []);
    return readNotifications.contains(notificationId);
  }

  /// Mark notification as deleted
  Future<void> markAsDeleted(int notificationId) async {
    final List<int> deletedNotifications = 
        List<int>.from(_storage.read(_deletedNotificationsKey) ?? []);
    
    if (!deletedNotifications.contains(notificationId)) {
      deletedNotifications.add(notificationId);
      await _storage.write(_deletedNotificationsKey, deletedNotifications);
    }
  }

  /// Check if notification is deleted
  bool isDeleted(int notificationId) {
    final List<int> deletedNotifications = 
        List<int>.from(_storage.read(_deletedNotificationsKey) ?? []);
    return deletedNotifications.contains(notificationId);
  }

  /// Save unread count
  Future<void> saveUnreadCount(int count) async {
    await _storage.write(_unreadCountKey, count);
  }

  /// Get unread count
  int getUnreadCount() {
    return _storage.read<int>(_unreadCountKey) ?? 0;
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _storage.remove(_allNotificationsKey);
    await _storage.remove(_lastRefreshTimeKey);
    await _storage.remove(_readNotificationsKey);
    await _storage.remove(_deletedNotificationsKey);
    await _storage.remove(_unreadCountKey);
  }

  /// Clear read notifications list
  Future<void> clearReadNotifications() async {
    await _storage.remove(_readNotificationsKey);
  }

  /// Clear deleted notifications list
  Future<void> clearDeletedNotifications() async {
    await _storage.remove(_deletedNotificationsKey);
  }

  /// Add new notification to cache
  Future<void> addNotification(NotificationModel notification) async {
    final notifications = await getAllNotifications();
    notifications.insert(0, notification);
    await saveAllNotifications(notifications);
  }

  /// Update notification in cache
  Future<void> updateNotification(NotificationModel notification) async {
    final notifications = await getAllNotifications();
    final index = notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      notifications[index] = notification;
      await saveAllNotifications(notifications);
    }
  }

  /// Remove notification from cache
  Future<void> removeNotification(int notificationId) async {
    final notifications = await getAllNotifications();
    notifications.removeWhere((n) => n.id == notificationId);
    await saveAllNotifications(notifications);
  }

  /// Get filtered notifications (excluding deleted ones)
  Future<List<NotificationModel>> getFilteredNotifications() async {
    final notifications = await getAllNotifications();
    return notifications.where((notification) => !isDeleted(notification.id)).toList();
  }
}
