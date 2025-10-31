import 'package:get_storage/get_storage.dart';
import 'package:homy/models/users/notification.dart';

class NotificationStorageService {
  static const String _platformNotificationsKey = 'platform_notifications';
  static const String _userNotificationsKey = 'user_notifications';
  static const String _lastRefreshTimeKey = 'last_notification_refresh';
  static const String _viewedNotificationsKey = 'viewed_notifications';
  final _storage = GetStorage();

  Future<void> savePlatformNotifications(List<NotificationData> notifications) async {
    final List<Map<String, dynamic>> serializedList = 
        notifications.map((notification) => notification.toJson()).toList();
    await _storage.write(_platformNotificationsKey, serializedList);
  }

  Future<List<NotificationData>> getPlatformNotifications() async {
    final List<dynamic>? data = _storage.read(_platformNotificationsKey);
    if (data == null) return [];
    return data.map((item) => NotificationData.fromJson(item)).toList();
  }

  Future<void> saveUserNotifications(List<NotificationData> notifications) async {
    final List<Map<String, dynamic>> serializedList = 
        notifications.map((notification) => notification.toJson()).toList();
    await _storage.write(_userNotificationsKey, serializedList);
  }

  Future<List<NotificationData>> getUserNotifications() async {
    final List<dynamic>? data = _storage.read(_userNotificationsKey);
    if (data == null) return [];
    return data.map((item) => NotificationData.fromJson(item)).toList();
  }

  Future<void> saveLastRefreshTime() async {
    await _storage.write(_lastRefreshTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  bool shouldRefreshFromServer() {
    return true;
    final lastRefresh = _storage.read<int>(_lastRefreshTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return now - lastRefresh > 5 * 60 * 1000; // Refresh every 5 minutes
  }

  Future<void> clearNotifications() async {
    await _storage.remove(_platformNotificationsKey);
    await _storage.remove(_userNotificationsKey);
    await _storage.remove(_lastRefreshTimeKey);
  }

  Future<void> markNotificationAsViewed(String notificationId) async {
    final List<String> viewedNotifications = 
        List<String>.from(_storage.read(_viewedNotificationsKey) ?? []);
    
    if (!viewedNotifications.contains(notificationId)) {
      viewedNotifications.add(notificationId);
      await _storage.write(_viewedNotificationsKey, viewedNotifications);
    }
  }

  bool isNotificationViewed(String notificationId) {
    final List<String> viewedNotifications = 
        List<String>.from(_storage.read(_viewedNotificationsKey) ?? []);
    return viewedNotifications.contains(notificationId);
  }

  Future<void> clearViewedNotifications() async {
    await _storage.remove(_viewedNotificationsKey);
  }
} 