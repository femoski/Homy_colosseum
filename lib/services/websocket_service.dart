import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:homy/models/chat/chat_message.dart';
import 'package:homy/services/chat_storage_service.dart';
import 'package:homy/services/fcm_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:homy/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:homy/services/config_service.dart';

class WebSocketService extends GetxService {
  // Remove hardcoded URL and use config
  Future<String> get _wsUrl async {
   
    // Fallback static URL
    return 'ws://localhost';
  }

  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const int _maxReconnectAttempts = 1000;
  static const Duration _connectionCheckInterval = Duration(seconds: 10);
  static const Duration _connectionTimeout = Duration(seconds: 15);

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isConnected = false;
  final _connectionStateController = StreamController<bool>.broadcast();
  final ChatStorageService _storageService = ChatStorageService();
  bool _isReconnecting = false;
  bool _isConnecting = false;
  Completer<void>? _connectionCompleter;
  Timer? _connectionMonitorTimer;
  DateTime? _lastMessageTime;

  // Callbacks for different message types
  Function(ChatMessages)? onMessageReceived;
  Function(String, String)? onConversationOpen;
  Function(String, bool)? onTypingStatusChanged;
  Function(String, String)? onMessageStatusChanged;
  Function(bool)? onConnectionStateChanged;

  // Add auth service reference
  final AuthService _authService = Get.find<AuthService>();

  Stream<bool> get connectionState => _connectionStateController.stream;

  bool get _isMobilePlatform => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  StreamSubscription? _tokenSubscription;


  Future<WebSocketService> init() async {
    // Ensure config is loaded
    try {
      final configService = await ConfigService.getConfig();
      if (configService.config.value?.chatConfig.system != 'Websocket') {
        print('WebSocket service disabled - using ${configService.config.value?.chatConfig.system} instead');
        return this;
      }
    } catch (e) {
      print('Failed to get config, proceeding with WebSocket initialization: $e');
    }

    _startConnectionMonitoring();
    
    // Listen to token changes
    _tokenSubscription = _authService.tokenStream.listen((String newToken) {
      if (newToken.isNotEmpty) {
        if (!_isConnected) {
          _connectToWebSocket();
        }
      } else {
        // Token is empty, cleanup connection
        _cleanupConnection();
      }
    });

    // Initial connection if token exists
    if (_authService.token.isNotEmpty) {
      if (_isMobilePlatform) {
        // await _initBackgroundService();
      }
      await _connectToWebSocket();
    }

    _setupConnectivityListener();
    return this;
  }

  Future<void> _connectToWebSocket() async {
    if (_isConnecting) {
      await _connectionCompleter?.future;
      return;
    }

    _isConnecting = true;
    _connectionCompleter = Completer<void>();
    StreamSubscription? authListener;

    try {
      final token = _authService.token;
      if (token.isEmpty) {
        throw Exception('No authentication token available');
      }

      final uri = Uri.parse(await _wsUrl);
      _channel = WebSocketChannel.connect(uri);
      
      // Wait for connection with timeout
      await _channel?.ready.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('WebSocket connection timeout'),
      );

      // Create auth completer before setting up listener
      Completer<bool> authCompleter = Completer<bool>();
      
      // Setup message handler that handles both auth and regular messages
      _channel?.stream.listen(
        (message) async {
          try {
            final data = jsonDecode(message as String);
            
            if (data['type'] == 'auth_response') {
              if (data['status'] == 'success') {
                authCompleter.complete(true);
                _isConnected = true;
                _handleConnectionStateChange(true);
                _reconnectAttempts = 0;
                // _startHeartbeat();
                await _processUndeliveredMessages();
              } else {
                authCompleter.completeError(data['message'] ?? 'Authentication failed');
              }
              return;
            }
            
            // Handle other messages only after auth is complete
            if (_isConnected) {
              _handleMessage(message);
            }
          } catch (e) {
            print('Error handling message: $e');
            if (!authCompleter.isCompleted) {
              authCompleter.completeError('Failed to parse auth response');
            }
          }
        },
        onError: (error) {
          print('WebSocket stream error: $error');
          _handleError(error);
          if (!authCompleter.isCompleted) {
            authCompleter.completeError('Auth listener error: $error');
          }
        },
        onDone: () {
          print('WebSocket connection closed');
          _handleDisconnection();
        },
        cancelOnError: false,
      );

      // Send auth message
      _channel?.sink.add(jsonEncode({
        'type': 'auth',
        'token': token,
        'time': DateTime.now().millisecondsSinceEpoch,
      }));

      // Wait for auth response with timeout
      try {
        await authCompleter.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('Authentication timeout'),
        );
        _connectionCompleter?.complete();
      } catch (e) {
        throw Exception('Authentication failed: $e ${_channel?.hashCode}');
      }
    } catch (e) {
      print('WebSocket connection error: $e');
      _cleanupConnection();
      _connectionCompleter?.completeError(e);
      _reconnectToWebSocket();
    } finally {
      _isConnecting = false;
      _connectionCompleter = null;
    }
  }

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        // Only check if we're not connected and there's network connectivity
        if (!_isConnected) {
          _reconnectToWebSocket();
        }
      } else {
        _handleDisconnection();
      }
    });
  }

  void _handleMessage(dynamic message) {
    // Update last message time whenever we receive any message
    _lastMessageTime = DateTime.now();
    
    try {
      final data = jsonDecode(message as String);
      
      switch (data['type']) {
        case 'auth_response':
          if (data['status'] == 'success') {
            print('WebSocket authentication successful');
          } else {
            print('WebSocket authentication failed: ${data['message']}');
            _handleError('Authentication failed');
          }
          break;
          
        case 'message':
          final chat = ChatMessages.fromJson(data['payload']['message']);
          // Store message in ChatStorageService
          _storageService.addNewMessage(
            chat.fromId.toString(), 
            chat
          ).then((_) {
            // Show notification for new message
            if (!_isPageActive) {
              Get.find<FCMService>().showMessageNotification(chat);
            }
            // Notify any active listeners
            onMessageReceived?.call(chat);
          });
          break;
          case 'conversation_open':
          _storageService.updateOpenConversation(data['payload']['to_id'].toString());
          // Store message in ChatStorageService
          break;
          
        case 'ping':
          _sendPong();
          break;
           case 'user_status':
           _sendUserStatus(data['user_id'].toString(), data['status'].toString());
          break;

            
        case 'typing':
          onTypingStatusChanged?.call(
            data['userId'],
            data['isTyping'],
          );
          break;
          
        case 'message_status':
        _storageService.updateMessageStatus(
          conversationId: data['payload']['conversationId'].toString(),
          uniqueId: data['payload']['unique_id'].toString(),
          status: data['payload']['status'].toString(),
          messageId: data['payload']['message_id'].toString(),
          message: ChatMessages.fromJson(data['payload']['message']??{}),
        ).then((_) {
            onMessageStatusChanged?.call(
              data['payload']['message_id'].toString(),
              data['payload']['status'],
            );
        });
          break;

        case 'pong':
          // Update last message time for pong responses
          _lastMessageTime = DateTime.now();
          break;
      }
    } catch (e) {
      print('Error handling message: $e');
    }
  }

void _sendUserStatus(String userId, String isOnline) {
  _storageService.updateUserStatus(userId,isOnline);
  // _sendMessage({
  //   'type': 'user_status',
  //   'user_id': userId,
  //   'status': isOnline ? 'online' : 'offline',
  // });
}
  void _sendPong() {
    _sendMessage({
      'type': 'pong',
      'time': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _cleanupConnection();
    _reconnectToWebSocket();
  }

  void _handleDisconnection() {
    _cleanupConnection();
    _reconnectToWebSocket();
  }

  Future<void> _reconnectToWebSocket() async {
    if (_isConnecting || _isReconnecting) return;

    try {

         // Check for actual internet connectivity before attempting reconnection
      final result = await Connectivity().checkConnectivity();
      if (result == ConnectivityResult.none) {
        print('No network connectivity - delaying reconnection');
        return;
      }

      if (_reconnectAttempts >= _maxReconnectAttempts) {
        print('Max reconnection attempts reached');
        return;
      }

      // Remove max reconnect attempts limit
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(_reconnectDelay, () async {
        _reconnectAttempts++;
        print('Attempting to reconnect (attempt ${_reconnectAttempts})');
        await _connectToWebSocket();
      });
    } catch (e) {
      print('Error during reconnection: $e');
      // Even if reconnection fails, we'll try again on next monitoring cycle
    }
  }

  Future<void> sendMessage(ChatMessages message) async {
    if (!_isConnected) {
      await _storageService.saveUndeliveredMessage(message);
      throw Exception('WebSocket connection not established');
    }

    try {
      Map<String, dynamic> messageWrapper = {
        'type': 'message',
        'payload': message.toJson(),
      };
      
      _channel?.sink.add(jsonEncode(messageWrapper));
      
      // Wait briefly to confirm the message was sent
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!_isConnected) {
        throw Exception('Lost connection while sending message');
      }
    } catch (e) {
      print('Error sending message: $e');
      await _storageService.saveUndeliveredMessage(message);
      rethrow;
    }
  }

  Future<void> _processUndeliveredMessages() async {
    if (_isReconnecting) return;
    
    _isReconnecting = true;
    try {
      final undeliveredMessages = await _storageService.getUndeliveredMessages();
      final successfullyDelivered = <int>[]; // Track successfully sent message times
      
      for (var messageJson in undeliveredMessages) {
        if (!_isConnected) break;
        
        try {
          Map<String, dynamic> message = {
            'type': 'message',
            'payload': messageJson,
          }; 
          
          _channel?.sink.add(jsonEncode(message));
          successfullyDelivered.add(messageJson['time']); // Add to successful list
          
        } catch (e) {
          print('Error resending message: $e');
        }
      }
      
      // Remove successfully delivered messages after iteration is complete
      for (final timeId in successfullyDelivered) {
        await _storageService.removeUndeliveredMessage(timeId);
      }
      
    } finally {
      _isReconnecting = false;
    }
  }

  void sendTypingStatus(String conversationId, bool isTyping) {
    _sendMessage({
      'type': 'typing',
      'conversationId': conversationId,
      'isTyping': isTyping,
    });
  }

  void sendMessageStatus(String messageId, String status,String fromId) {
    if(_isPageActive){
    _sendMessage({
      'type': 'message_status',
      'messageId': messageId,
      'status': status,
      'fromId': fromId,
    });
    }
  }

    void sendConversationOpen(String conversationId) {
    _sendMessage({
      'type': 'conversation_open',
      'conversationId': conversationId,
    });
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_isConnected) {
      try {
        _channel?.sink.add(jsonEncode(message));
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  void sendMediaMessage(Map<String, dynamic> message) {
    if (_isConnected) {
      try {
        _channel?.sink.add(jsonEncode(message));
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  Future<void> _initBackgroundService() async {
    // await _backgroundService.configure(
    //   iosConfiguration: IosConfiguration(
    //     autoStart: false,
    //     onForeground: _onBackgroundStart,
    //     onBackground: _onBackgroundStart,
    //   ),
    //   androidConfiguration: AndroidConfiguration(
    //     onStart: _onBackgroundStart,
    //     autoStart: false,
    //     isForegroundMode: true,
    //   ),
    // );
  }

  // @pragma('vm:entry-point')
  // static Future<bool> _onBackgroundStart(ServiceInstance service) async {
  //   service.on('keepAlive').listen((event) {
  //     final webSocketService = Get.find<WebSocketService>();
  //     if (!webSocketService._isConnected) {
  //       webSocketService._reconnectToWebSocket();
  //     }
  //   });

  //   Timer.periodic(_backgroundCheckInterval, (timer) {
  //     service.invoke('keepAlive');
  //   });
    
  //   return true;
  // }

  @override
  void onClose() {
    _tokenSubscription?.cancel();
    // if (_isMobilePlatform) {
    //   _backgroundService.invoke('stopService');
    // }
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _connectionStateController.close();
    _connectionMonitorTimer?.cancel();
    super.onClose();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        try {
          _sendMessage({
            'type': 'ping',
            'time': DateTime.now().millisecondsSinceEpoch,
          });
        } catch (e) {
          print('Failed to send heartbeat: $e');
          _handleError(e);
        }
      }
    });
  }

  Future<bool> checkConnection() async {
    if (!_isConnected) return false;
    
    try {
      _sendMessage({
        'type': 'ping',
        'time': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  void _handleConnectionStateChange(bool isConnected) {
    _connectionStateController.add(isConnected);
    onConnectionStateChanged?.call(isConnected);
    
    // Process undelivered messages when connection is restored
    if (isConnected) {
      _processUndeliveredMessages();
    }
  }

  // Add this new method to handle connection cleanup
  void _cleanupConnection([StreamSubscription? authListener]) {
    authListener?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _isConnected = false;
    _handleConnectionStateChange(false);
    _heartbeatTimer?.cancel();
    // Don't cancel connection monitor - we want it to keep trying to reconnect
  }

  void _startConnectionMonitoring() {
    _connectionMonitorTimer?.cancel();
    _connectionMonitorTimer = Timer.periodic(_connectionCheckInterval, (timer) async {
      // Always try to reconnect if not connected, regardless of other conditions
      if (!_isConnected) {
        _reconnectToWebSocket();
        return;
      }

      // Check connection health if connected
      if (_lastMessageTime != null && 
          DateTime.now().difference(_lastMessageTime!) > _connectionTimeout) {
        print('Connection seems dead - no messages received recently');
        // _handleDisconnection();
        return;
      }

      // Proactively test connection with ping
      try {
        _sendMessage({
          'type': 'ping',
          'time': DateTime.now().millisecondsSinceEpoch,
        });
      } catch (e) {
        print('Failed to send ping: $e');
        _handleDisconnection();
      }
    });
  }

  // Future<void> _initializeLocalNotifications() async {
  //   const AndroidInitializationSettings androidSettings = 
  //       AndroidInitializationSettings('@mipmap/ic_launcher');
    
  //   const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestSoundPermission: true,
  //   );
    
  //   const InitializationSettings initSettings = InitializationSettings(
  //     android: androidSettings,
  //     iOS: iOSSettings,
  //   );

  //   await _flutterLocalNotificationsPlugin.initialize(
  //     initSettings,
  //     onDidReceiveNotificationResponse: (NotificationResponse response) {
  //       // Handle notification tap
  //       _handleNotificationTap(response);
  //     },
  //   );
  // }

  // void _handleNotificationTap(NotificationResponse response) async {
  //   if (response.payload != null) {
  //     try {

  //       Get.log('response.payload: ${response.payload}');
  //       final data = jsonDecode(response.payload!);
  //       if (data['type'] == 'chat_message') {
  //         // Navigate to chat screen
  //         ChatListItem? conversation = await _storageService.getConversationById(data['conversation_id']);
  //         if (conversation != null) {
  //           HelperUtils.push(
  //             Get.context!,
  //             MessageBox(conversation: conversation, screen: 1),
  //           );
  //         }                    
  //         //Get.toNamed('/chat', arguments: {'conversation_id': data['conversation_id']});
  //       }
  //     } catch (e) {
  //       print('Error handling notification tap: $e');
  //     }
  //   }
  // }

  

  bool _isPageActive = false;
  set isPageActive(bool value) {
    _isPageActive = value;
  }
} 
  