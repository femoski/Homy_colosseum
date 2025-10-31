import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/repositories/notifications/notifications_repository.dart';
import 'package:homy/services/notifications/notification_storage_service.dart';

/// Shared notification service to manage notification count across the app
/// This ensures all controllers stay synchronized with the same notification count
class SharedNotificationService extends GetxService {
  static SharedNotificationService get instance => Get.find<SharedNotificationService>();
  
  final NotificationsRepository _repository = NotificationsRepository();
  final NotificationStorageService _storageService = NotificationStorageService();

  // Observable unread count that all controllers can listen to
  final RxInt _unreadCount = 0.obs;
  
  // Getters
  int get unreadCount => _unreadCount.value;
  RxInt get unreadCountStream => _unreadCount;

  @override
  void onInit() {
    super.onInit();
    _loadCachedCount();
    Get.log('SharedNotificationService initialized with cached count: ${_unreadCount.value}');
    // Automatically load unread count from server on app start if user is logged in
    loadUnreadCount();

  }

  /// Load unread count from cache first, then from server
  Future<void> loadUnreadCount() async {
    try {
      Get.log('Loading unread count from server...');
      final count = await _repository.getUnreadCount();
      _unreadCount.value = count;
      await _storageService.saveUnreadCount(count);
      Get.log('Successfully loaded unread count from server: $count');
    } catch (e) {
      // Use cached count on error
      _unreadCount.value = _storageService.getUnreadCount();
      Get.log('Failed to load unread count from server, using cached: ${_unreadCount.value}. Error: $e');
    }
  }

  /// Load cached count on initialization
  void _loadCachedCount() {
    _unreadCount.value = _storageService.getUnreadCount();
  }

  /// Update unread count (used when notifications are marked as read/unread)
  void updateUnreadCount(int newCount) {
    _unreadCount.value = newCount;
    _storageService.saveUnreadCount(newCount);
  }

  /// Increment unread count (used when new notification arrives)
  void incrementUnreadCount() {
    _unreadCount.value++;
    _storageService.saveUnreadCount(_unreadCount.value);
  }

  /// Decrement unread count (used when notification is marked as read)
  void decrementUnreadCount() {
    if (_unreadCount.value > 0) {
      _unreadCount.value--;
      _storageService.saveUnreadCount(_unreadCount.value);
    }
  }

  /// Reset unread count to zero (used when all notifications are marked as read)
  void resetUnreadCount() {
    _unreadCount.value = 0;
    _storageService.saveUnreadCount(0);
  }

  /// Add new notification and update count if unread
  void addNotification(bool isRead) {
    if (!isRead) {
      incrementUnreadCount();
    }
  }

  /// Mark notification as read and update count
  void markAsRead() {
    decrementUnreadCount();
  }

  /// Mark notification as unread and update count
  void markAsUnread() {
    incrementUnreadCount();
  }

  /// Mark all notifications as read and reset count
  void markAllAsRead() {
    resetUnreadCount();
  }

  /// Handle user login - load notification count
  void onUserLogin() {
    loadUnreadCount();
  }

  /// Handle user logout - reset notification count
  void onUserLogout() {
    resetUnreadCount();
  }
}
