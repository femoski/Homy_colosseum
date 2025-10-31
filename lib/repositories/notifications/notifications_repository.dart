import 'package:get/get.dart';
import 'package:homy/models/notifications/notification_model.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';

class NotificationsRepository {
  final ApiClient _apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  /// Fetch all notifications with pagination
  Future<NotificationResponse> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiClient.getData(
        'notifications',
        query: query,
      );

      if (response.statusCode == 200) {
        return NotificationResponse.fromJson(response.body);
      } else {
        throw Exception('Failed to fetch notifications: ${response.statusText}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch notifications: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await _apiClient.postData(
        'notifications/mark-read/$notificationId',
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
  /// Mark a notification as unread
  Future<void> markAsUnread(int notificationId) async {
    try {
      final response = await _apiClient.postData(
        'notifications/mark-unread/$notificationId',
        {},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as unread: ${response.statusText}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark notification as unread: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  } 

    /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await _apiClient.postData(
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

  /// Delete a notification (logical delete for user)
  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await _apiClient.postData(
        'notifications/delete/$notificationId',
        {},
      );

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

  /// Clear all notifications (logical delete for user)
  Future<void> clearAllNotifications() async {
    try {
      final response = await _apiClient.postData(
        'notifications/clear-all',
        {},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to clear all notifications: ${response.statusText}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear all notifications: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.getData('notifications/unread-count');

      if (response.statusCode == 200) {
        // Handle different possible response structures
        final data = response.body['data'];
        if (data is Map<String, dynamic>) {
          return data['unread_count'] as int? ?? 0;
        } else if (data is int) {
          return data;
        } else {
          return 0;
        }
      } else {
        throw Exception('Failed to fetch unread count: ${response.statusText}');
      }
    } catch (e) {
      return 0; // Return 0 on error to avoid breaking the UI
    }
  }

  /// Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final response = await _apiClient.getData('notifications/settings');

      if (response.statusCode == 200) {
        return response.body['data'] as Map<String, dynamic>? ?? {};
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

  /// Update notification settings
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      final response = await _apiClient.postData(
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
}
