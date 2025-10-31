import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/models/users/notification.dart';
import 'package:homy/models/users/user_notification.dart';
// import 'package:homy/models/users/user_notification.dart';

import '../../../repositories/notifications_repository.dart';
import 'package:homy/services/notification_storage_service.dart';

class NotificationController extends GetxController {
  List<NotificationData> notifications = [];
  List<NotificationData> userNotifications = [];
  ScrollController scrollController = ScrollController();
  bool hasMoreData = true;
  int selectedTab = 0;
  bool isLoading = false;
  final NotificationsRepository _notificationsRepository = NotificationsRepository();
  final NotificationStorageService _storageService = NotificationStorageService();

  @override
  void onInit() {
    super.onInit();
    loadNotificationsFromCache();
    scrollToFetchData();
  }
  @override
  void onReady() {
    super.onReady();
    // callApi();
    scrollToFetchData();
  }

  Future<void> loadNotificationsFromCache() async {
    isLoading = true;
    update();

    try {
      if (selectedTab == 0) {
        final cachedNotifications = await _storageService.getPlatformNotifications();
        if (cachedNotifications.isNotEmpty) {
          notifications = cachedNotifications;
          update();
        }
      } else if (AuthHelper.isLoggedIn()) {
        final cachedNotifications = await _storageService.getUserNotifications();
        if (cachedNotifications.isNotEmpty) {
          userNotifications = cachedNotifications;
          update();
        }
      }

      if (notifications.isEmpty && userNotifications.isEmpty || _storageService.shouldRefreshFromServer()) {
        await callApi();
      }
    } catch (e) {
      print('Error loading notifications from cache: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  callApi() {
    if (selectedTab == 0) {
      fetchNotificationApiCall();
    } else {
      if (AuthHelper.isLoggedIn()) {
        fetchUserNotification();
      } else {
        isLoading = false;
        update();
      }
    }
  }

  Future<void> fetchNotificationApiCall() async {
    if (!hasMoreData) return;
    isLoading = true;
    update();

    try {
      final response = await _notificationsRepository.getPlatformNotifications();
      notifications = response;
      await _storageService.savePlatformNotifications(response);
      await _storageService.saveLastRefreshTime();
      update();
    } catch (e) {
      print('Error fetching platform notifications: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> refreshNotification() async {
    if (!hasMoreData) return;
    isLoading = true;
    update();
    
    if (selectedTab == 0) {
      fetchNotificationApiCall();
    } else {
      fetchUserNotification();
    }
    
  }

  Future<void> fetchUserNotification() async {
    if (!hasMoreData) return;
    isLoading = true;
    update();

    try {
      final response = await _notificationsRepository.getUserNotifications();
      userNotifications = response;
      await _storageService.saveUserNotifications(response);
      await _storageService.saveLastRefreshTime();
      update();
    } catch (e) {
      print('Error fetching user notifications: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  void scrollToFetchData() {
    scrollController.addListener(() {
      if (scrollController.offset >= scrollController.position.maxScrollExtent) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!isLoading) {
            callApi();
          }
        });
      }
    });
  }

  onNotificationTabTap(int index) {
    scrollController = ScrollController();
    hasMoreData = true;
    isLoading = true;
    selectedTab = index;
    // notifications = [];
    // userNotifications = [];
    update();
    loadNotificationsFromCache();
  }

  Future<void> markNotificationAsViewed(dynamic notification) async {
    try {
      String notificationId;
      if (notification is NotificationData) {
        notificationId = 'platform_${notification.id}';
      } else if (notification is UserNotificationData) {
        notificationId = 'user_${notification.id}';
      } else {
        return;
      }

      await _storageService.markNotificationAsViewed(notificationId);
      
      // Update the notification's isRead state
      if (notification is NotificationData) {
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index] = notification.copyWith(isRead: true);
        }
      } else if (notification is NotificationData) {
        final index = userNotifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          userNotifications[index] = notification.copyWith(isRead: true);
        }
      }
      
      update();
    } catch (e) {
      print('Error marking notification as viewed: $e');
    }
  }

  bool isNotificationViewed(dynamic notification) {
    try {
      String notificationId;
      if (notification is NotificationData) {
        notificationId = 'platform_${notification.id}';
      } else if (notification is UserNotificationData) {
        notificationId = 'user_${notification.id}';
      } else {
        return false;
      }

      return _storageService.isNotificationViewed(notificationId);
    } catch (e) {
      print('Error checking notification viewed state: $e');
      return false;
    }
  }
}
