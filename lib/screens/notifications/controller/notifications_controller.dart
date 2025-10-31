import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/notifications/notification_model.dart';
import 'package:homy/repositories/notifications/notifications_repository.dart';
import 'package:homy/services/notifications/notification_storage_service.dart';
import 'package:homy/services/notifications/shared_notification_service.dart';

class NotificationsController extends GetxController {
  final NotificationsRepository _repository = NotificationsRepository();
  final NotificationStorageService _storageService = NotificationStorageService();
  late final SharedNotificationService _sharedNotificationService;

  // Observable lists
  final RxList<NotificationModel> _allNotifications = <NotificationModel>[].obs;

  // State variables
  final RxBool _isLoading = false.obs;
  final RxBool _isRefreshing = false.obs;
  final RxBool _hasMore = true.obs;
  final RxInt _currentPage = 1.obs;
  final RxString _error = ''.obs;

  // Scroll controller
  final ScrollController scrollController = ScrollController();

  // Getters
  List<NotificationModel> get allNotifications => _allNotifications;
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  bool get hasMore => _hasMore.value;
  String get error => _error.value;
  int get unreadCount => _sharedNotificationService.unreadCount;

  @override
  void onInit() {
    super.onInit();
    _sharedNotificationService = Get.find<SharedNotificationService>();
    _setupScrollListeners();
    loadNotificationsFromCache();
    loadNotifications();
    loadUnreadCount();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _setupScrollListeners() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= 
          scrollController.position.maxScrollExtent - 200) {
        if (!isLoading && hasMore) {
          loadMoreNotifications();
        }
      }
    });
  }

  /// Load notifications from cache first
  Future<void> loadNotificationsFromCache() async {
    try {
      final cachedNotifications = await _storageService.getFilteredNotifications();
      
      _allNotifications.assignAll(cachedNotifications);
      
      // Load from server if cache is empty or should refresh
      if (cachedNotifications.isEmpty || _storageService.shouldRefreshFromServer()) {
        await loadNotifications();
      }
    } catch (e) {
      _error.value = 'Failed to load cached notifications: $e';
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: _error.value));
    }
  }

  /// Load notifications from server
  Future<void> loadNotifications() async {
    if (isLoading) return;
    
    _isLoading.value = true;
    _error.value = '';
    
    try {
      final response = await _repository.getNotifications(page: 1, limit: 20);
      
      _allNotifications.assignAll(response.data);
      _hasMore.value = response.data.length >= 20; // Assume hasMore if we got a full page
      _currentPage.value = 1;
      
      // Save to cache
      await _storageService.saveAllNotifications(response.data);
      await _storageService.saveLastRefreshTime();
    } catch (e) {
      _error.value = 'Failed to load notifications: $e';
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: _error.value));
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load more notifications
  Future<void> loadMoreNotifications() async {
    if (isLoading || !hasMore) return;
    
    _isLoading.value = true;
    
    try {
      final nextPage = _currentPage.value + 1;
      final response = await _repository.getNotifications(page: nextPage, limit: 20);
      
      _allNotifications.addAll(response.data);
      _hasMore.value = response.data.length >= 20; // Assume hasMore if we got a full page
      _currentPage.value = nextPage;
      
      // Update cache
      final allNotifications = await _storageService.getAllNotifications();
      allNotifications.addAll(response.data);
      await _storageService.saveAllNotifications(allNotifications);
    } catch (e) {
      _error.value = 'Failed to load more notifications: $e';
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: _error.value));
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    if (isRefreshing) return;
    
    _isRefreshing.value = true;
    _error.value = '';
    
    try {
      _currentPage.value = 1;
      _hasMore.value = true;
      
      await loadNotifications();
      await loadUnreadCount();
    } catch (e) {
      _error.value = 'Failed to refresh notifications: $e';
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: _error.value));
    } finally {
      _isRefreshing.value = false;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(NotificationModel notification) async {
    Get.log('Marking notification as read: ${notification.id}');

    try {
      // Optimistic update
      final updatedNotification = notification.copyWith(isRead: true);
      _updateNotificationInList(updatedNotification);
      
      // Update cache
      await _storageService.markAsRead(notification.id);
      await _storageService.updateNotification(updatedNotification);
      
      // Call API
      await _repository.markAsRead(notification.id);
      
      // Update unread count through shared service
      _sharedNotificationService.markAsRead();
    } catch (e) {
      // Rollback on error
      final rollbackNotification = notification.copyWith(isRead: false);
      _updateNotificationInList(rollbackNotification);
      
      _error.value = 'Failed to mark notification as read: $e';
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: _error.value));
    }
  }

  /// Mark notification as unread
  Future<void> markAsUnread(NotificationModel notification) async {
    try {
      // Optimistic update
      final updatedNotification = notification.copyWith(isRead: false);
      _updateNotificationInList(updatedNotification);
      
      // Update cache
      await _storageService.updateNotification(updatedNotification);
      
      // Call API
      await _repository.markAsUnread(notification.id);
      
      // Update unread count through shared service
      _sharedNotificationService.markAsUnread();
    } catch (e) {
      // Rollback on error
      final rollbackNotification = notification.copyWith(isRead: true);
      _updateNotificationInList(rollbackNotification);
      
      _error.value = 'Failed to mark notification as unread: $e';
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: _error.value));
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      // Optimistic update
      for (int i = 0; i < _allNotifications.length; i++) {
        _allNotifications[i] = _allNotifications[i].copyWith(isRead: true);
      }
      
      // Call API 
      await _repository.markAllAsRead();
      
      // Update cache
      await _storageService.clearReadNotifications();
      await _storageService.saveAllNotifications(_allNotifications);
      
      // Update unread count through shared service
      _sharedNotificationService.markAllAsRead();
      
      Get.showSnackbar(CommonUI.SuccessSnackBar(message: 'All notifications marked as read'));

    } catch (e) {
      _error.value = 'Failed to mark all notifications as read: $e';
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: _error.value));
    }
  }

  /// Delete notification
  Future<void> deleteNotification(NotificationModel notification) async {
    try {
      // Optimistic update - remove from list
      _removeNotificationFromList(notification);
      
      // Update cache
      await _storageService.markAsDeleted(notification.id);
      await _storageService.removeNotification(notification.id);
      
      // Call API
      await _repository.deleteNotification(notification.id);
        // Update unread count through shared service
      _sharedNotificationService.loadUnreadCount();
      Get.showSnackbar(CommonUI.SuccessSnackBar(message: 'Notification deleted'));

    } catch (e) {
      // Rollback on error
      _addNotificationToList(notification);
      
      _error.value = 'Failed to delete notification: $e';
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: _error.value));
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Clear All Notifications'),
          content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Clear All'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Optimistic update
      _allNotifications.clear();
      
      // Call API
      await _repository.clearAllNotifications();
      
      // Update cache
      await _storageService.clearAllNotifications();
      
      // Update unread count through shared service
      _sharedNotificationService.resetUnreadCount();
      
      Get.showSnackbar(CommonUI.SuccessSnackBar(message: 'All notifications cleared'));
    } catch (e) {
      _error.value = 'Failed to clear all notifications: $e';
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: _error.value));
    }
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    await _sharedNotificationService.loadUnreadCount();
  }

  /// Add new notification (for FCM)
  Future<void> addNotification(NotificationModel notification) async {
    try {
      _addNotificationToList(notification);
      await _storageService.addNotification(notification);
      
      // Update unread count through shared service
      _sharedNotificationService.addNotification(notification.isRead);
    } catch (e) {
      _error.value = 'Failed to add notification: $e';
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: _error.value));
    }
  }

  /// Update notification in list
  void _updateNotificationInList(NotificationModel notification) {
    final index = _allNotifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      _allNotifications[index] = notification;
    }
  }

  /// Remove notification from list
  void _removeNotificationFromList(NotificationModel notification) {
    _allNotifications.removeWhere((n) => n.id == notification.id);
  }

  /// Add notification to list
  void _addNotificationToList(NotificationModel notification) {
    _allNotifications.insert(0, notification);
    // Sort to maintain chronological order
    _allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
