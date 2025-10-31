import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:homy/models/chat/chat_list.dart';
import 'package:homy/models/chat/chat_message.dart';
import 'package:homy/screens/chat_screen/message_box.dart';
import 'package:homy/screens/chat_screen/controllers/chat_controller.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/repositories/user_repository.dart';
import 'package:homy/services/chat_storage_service.dart';
import 'package:homy/utils/helpers/helper_utils.dart';

class FCMService extends GetxService {
  static const String _allUsersTopic = 'all_users';
  static const String _agentsTopic = 'role_agents';
  static const String _usersTopic = 'role_users';
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  final ChatStorageService _storageService = ChatStorageService();
  
  // Observable for FCM token
  final Rx<String?> fcmToken = Rx<String?>(null);

  Future<FCMService> init() async {
    try {
      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        Get.log('User granted permission for notifications');
        
        // Initialize local notifications
        await _initializeLocalNotifications();
        
        // Get and setup FCM token
        await _setupFCMToken();
        
        // Setup message handlers
        _setupMessageHandlers();
      } else {
        Get.log('User declined or has not accepted notification permissions');
      }
    } catch (e) {
      Get.log('Error initializing FCM service: $e');
    }

    return this;
  }

  Future<void> _setupFCMToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null) {
        fcmToken.value = token;
        Get.log('FCM Token: $token');
        await updateFCMTokenOnServer(token);
        await _setupTopicSubscriptions();
      } else {
        Get.log('Failed to get FCM token: token is null');
      }
    } catch (e) {
      Get.log('Error getting FCM token: $e');
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(
      (newToken) async {
        fcmToken.value = newToken;
        await updateFCMTokenOnServer(newToken);
        await _setupTopicSubscriptions();
      },
      onError: (error) {
        Get.log('Error on token refresh: $error');
      },
    );
  }

  Future<void> _setupTopicSubscriptions() async {
    try {
      // Subscribe to all_users topic
      await subscribeToTopic(_allUsersTopic);
      
      // Subscribe to role-specific topics
      final authService = await AuthService.getAuth();
      if (authService.isAuth && authService.role == 'agent') {
        await subscribeToTopic(_agentsTopic);
      } else if (authService.isAuth && authService.role == 'user') {
        await subscribeToTopic(_usersTopic);
      }
    } catch (e) {
      Get.log('Error setting up topic subscriptions: $e');
    }
  }

  void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when user taps on notification when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Request iOS permissions separately
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    Get.log('Received foreground message: ${message.messageId}');
    Get.log('Received foreground message: ${message.data}');

    // if (message.data['type'] == 'chat') {
    //   // Handle chat navigation
    //   _navigateToChat(message.data);
    // } else if (message.data['type'] == 'property') {
    //   // Handle property navigation
    //   _navigateToProperty(message.data);
    // } else if (message.data['type'] == 'property_match') {
    //   // Handle property match notification
    //   _navigateToPropertyMatch(message.data);
    // }
    try {
      await _showLocalNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      Get.log('Error handling foreground message: $e');
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    Get.log('Handling background message: ${message.messageId}');
    
    try {
      if (message.data['type'] == 'chat') {
        // Handle chat navigation
        _navigateToChat(message.data);
      } else if (message.data['type'] == 'property') {
        // Handle property navigation
        _navigateToProperty(message.data);
      } else if (message.data['type'] == 'property_match') {
        // Handle property match notification
        _navigateToPropertyMatch(message.data);
      }
    } catch (e) {
      Get.log('Error handling background message: $e');
    }
  }

  void _navigateToChat(Map<String, dynamic> data) {
    // Implement chat navigation logic
    Get.log('Navigating to chat with data: $data');

    HelperUtils.push(
      Get.context!,
      MessageBox(conversation: data['conversation_id'], screen: 1),
    );
  }

  void _navigateToProperty(Map<String, dynamic> data) {
    // Implement property navigation logic
    Get.log('Navigating to property with data: $data');
  }

  void _navigateToPropertyMatch(Map<String, dynamic> data) {
    // Navigate to property details when user taps on property match notification
    final propertyId = data['property_id'];
    if (propertyId != null) {
      Get.toNamed('/property-details/$propertyId');
    }
    Get.log('Navigating to property match with data: $data');
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'homy_default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel for Homy app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: 1,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      Get.log('Error showing local notification: $e');
    }
  }

  Future<void> showMessageNotification(ChatMessages message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        message.time ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        message.messageUser?.name ?? 'New Message',
        _getMessageBody(message),
        details,
        payload: jsonEncode({
          'type': 'chat_message',
          'conversation_id': message.fromId.toString(),
        }),
      );
    } catch (e) {
      Get.log('Error showing message notification: $e');
    }
  }

  String _getMessageBody(ChatMessages message) {
    if (message.text?.isEmpty ?? true) {
      switch (message.type) {
        case 'audio':
          return 'Audio Message';
        case 'image':
          return 'Image Message';
        case 'video':
          return 'Video Message';
        default:
          return 'New Message';
      }
    }
    return message.text!;
  }

  void _handleNotificationTap(NotificationResponse response) async {
    if (response.payload != null) {
      try {
        Get.log('Notification tapped with payload: ${response.payload}');
        final data = jsonDecode(response.payload.toString());
        
        if (data['type'] == 'chat_message') {
          await _handleChatNotificationTap(data);
        } else if (data['type'] == 'property_match') {
          _navigateToPropertyMatch(data);
        }
      } catch (e) {
        Get.log('Error handling notification tap: $e');
      }
    }
  }

  Future<void> showPropertyMatchNotification({
    required String propertyTitle,
    required String propertyType,
    required String location,
    required int propertyId,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'property_matches',
      'Property Matches',
      channelDescription: 'Notifications for properties matching your requirements',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        propertyId, // Use property ID as notification ID
        '🎉 New Property Match!',
        '$propertyType in $location within your budget!',
        details,
        payload: jsonEncode({
          'type': 'property_match',
          'property_id': propertyId.toString(),
        }),
      );
    } catch (e) {
      Get.log('Error showing property match notification: $e');
    }
  }

  Future<void> _handleChatNotificationTap(Map<String, dynamic> data) async {

    Get.log('Handling chat notification tap with data: ${data['conversation_id']}');

    ChatListItem? conversation = await _storageService.getConversationById(data['conversation_id'].toString());
    if (conversation != null) {
      Get.log('Navigating to chat with user: ${conversation.user.userId}');
      
      // Register MessageScreenController if not already registered
      if (!Get.isRegistered<MessageScreenController>()) {
        Get.put(MessageScreenController());
      }
      
      HelperUtils.push(
        Get.context!,
        MessageBox(conversation: conversation, screen: 1),
      );
    }
  }
  
  Future<void> updateFCMTokenOnServer(String token) async {
    try {
      final authService = await AuthService.getAuth();
      if (authService.isAuth) {
        final userRepository = UserRepository();
        await userRepository.updateFCMToken(token);
      }
    } catch (e) {
      Get.log('Error updating FCM token: $e');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      Get.log('Successfully subscribed to topic: $topic');
    } catch (e) {
      Get.log('Error subscribing to topic $topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      Get.log('Successfully unsubscribed from topic: $topic');
    } catch (e) {
      Get.log('Error unsubscribing from topic $topic: $e');
    }
  }
} 