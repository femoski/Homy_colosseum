import 'package:get/get.dart';
import 'package:homy/models/users/notification.dart';
import 'package:homy/models/users/user_notification.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';

class NotificationsRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  // Fetch platform notifications
  Future<List<NotificationData>> getPlatformNotifications({int start = 0, int limit = 20}) async {
    try {
      final response = await apiClient.getData(
        'notifications/platform',
        query: {
          'start': start.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> notificationsData = response.body['data']['notifications'];
        return notificationsData.map((data) => NotificationData.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch platform notifications: ${response.statusText}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch platform notifications: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Fetch user-specific notifications
  Future<List<NotificationData>> getUserNotifications({int start = 0, int limit = 20}) async {
    try {
      final response = await apiClient.getData(
        'notifications',
        query: {
          'start': start.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> notificationsData = response.body['data']['notifications'];
        return notificationsData.map((data) => NotificationData.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch user notifications: ${response.statusText}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch user notifications: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final response = await apiClient.postData(
        'notifications/$notificationId/read',
        {},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.statusText}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark notification as read: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final response = await apiClient.postData(
        'notifications/mark-all-read',
        {},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read: ${response.statusText}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark all notifications as read: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await apiClient.deleteData('notifications/$notificationId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification: ${response.statusText}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete notification: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final response = await apiClient.getData('notifications/settings');

      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw Exception('Failed to fetch notification settings: ${response.statusText}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch notification settings: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      final response = await apiClient.postData(
        'notifications/settings',
        settings,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update notification settings: ${response.statusText}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update notification settings: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  Future<int> notificationCount() async {
    try {
      final response = await apiClient.getData('notifications/unread/count');
      if (response.statusCode == 200) {
        return response.body['data']['unread_count'];
      } else {
        throw Exception('Failed to fetch notification count: ${response.statusText}');
      }
    } catch (e) {
      rethrow;
    }
  }
} 
