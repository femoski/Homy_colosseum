import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as local_notifications;
import 'package:get/get.dart';
import 'package:homy/screens/notifications/controller/notifications_controller.dart';
import 'package:homy/models/notifications/notification_model.dart';

class FCMNotificationService extends GetxService {
  static const String _notificationsChannelId = 'notifications_channel';
  static const String _notificationsChannelName = 'Notifications';
  static const String _notificationsChannelDescription = 'App notifications';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final local_notifications.FlutterLocalNotificationsPlugin _localNotifications = local_notifications.FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    _initializeLocalNotifications();
    _setupFCMHandlers();
  }

  Future<void> _initializeLocalNotifications() async {
    const local_notifications.AndroidInitializationSettings androidSettings = local_notifications.AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    
    const local_notifications.DarwinInitializationSettings iOSSettings = local_notifications.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const local_notifications.InitializationSettings initSettings = local_notifications.InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const local_notifications.AndroidNotificationChannel channel = local_notifications.AndroidNotificationChannel(
      _notificationsChannelId,
      _notificationsChannelName,
      description: _notificationsChannelDescription,
      importance: local_notifications.Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<local_notifications.AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _setupFCMHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when user taps on notification when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Handle initial message when app is opened from terminated state
    _messaging.getInitialMessage().then(_handleInitialMessage);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    Get.log('Received foreground message: ${message.messageId}');
    
    try {
      final notification = _parseNotificationFromMessage(message);
      if (notification != null) {
        // Add to notifications controller if available
        if (Get.isRegistered<NotificationsController>()) {
          final controller = Get.find<NotificationsController>();
          await controller.addNotification(notification);
        }

        // Show local notification
        await _showLocalNotification(notification);
      }
    } catch (e) {
      Get.log('Error handling foreground message: $e');
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    Get.log('Handling background message: ${message.messageId}');
    _navigateToNotification(message.data);
  }

  void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      Get.log('Handling initial message: ${message.messageId}');
      _navigateToNotification(message.data);
    }
  }

  void _handleNotificationTap(local_notifications.NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _navigateToNotification(data);
      } catch (e) {
        Get.log('Error handling notification tap: $e');
      }
    }
  }

  NotificationModel? _parseNotificationFromMessage(RemoteMessage message) {
    try {
      final data = message.data;
      if (data['type'] == 'notification') {
        return NotificationModel(
          id: int.tryParse(data['id']?.toString() ?? '0') ?? 0,
          userId: int.tryParse(data['user_id']?.toString() ?? ''),
          title: data['title'] ?? message.notification?.title ?? 'New Notification',
          message: data['description'] ?? data['message'] ?? message.notification?.body ?? '',
          createdAt: DateTime.now(),
          isRead: false,
          data: data,
        );
      }
    } catch (e) {
      Get.log('Error parsing notification from message: $e');
    }
    return null;
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    const local_notifications.AndroidNotificationDetails androidDetails = local_notifications.AndroidNotificationDetails(
      _notificationsChannelId,
      _notificationsChannelName,
      channelDescription: _notificationsChannelDescription,
      importance: local_notifications.Importance.high,
      priority: local_notifications.Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const local_notifications.DarwinNotificationDetails iOSDetails = local_notifications.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const local_notifications.NotificationDetails details = local_notifications.NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _localNotifications.show(
        notification.id,
        notification.title,
        notification.shortMessage,
        details,
        payload: jsonEncode(notification.toJson()),
      );
    } catch (e) {
      Get.log('Error showing local notification: $e');
    }
  }

  void _navigateToNotification(Map<String, dynamic> data) {
    try {
      final notificationId = data['notification_id'];
      if (notificationId != null) {
        // Navigate to notifications page
        Get.toNamed('/notifications');
        
        // If notifications controller is available, you could scroll to specific notification
        if (Get.isRegistered<NotificationsController>()) {
          // You could add logic here to scroll to specific notification
        }
      }
    } catch (e) {
      Get.log('Error navigating to notification: $e');
    }
  }

  /// Show in-app banner notification
  void showInAppBanner(NotificationModel notification) {
    Get.snackbar(
      notification.title,
      notification.shortMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(
        Icons.notifications_active_rounded,
        color: Colors.white,
      ),
      onTap: (snack) {
        Get.toNamed('/notifications');
      },
    );
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      Get.log('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      Get.log('Error getting FCM token: $e');
      return null;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      Get.log('Successfully subscribed to topic: $topic');
    } catch (e) {
      Get.log('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      Get.log('Successfully unsubscribed from topic: $topic');
    } catch (e) {
      Get.log('Error unsubscribing from topic $topic: $e');
    }
  }
}
