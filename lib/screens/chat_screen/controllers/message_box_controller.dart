import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/chat/chat_list.dart';
import 'package:homy/models/chat/chat_message.dart';
import 'package:homy/models/chat/property_message.dart';
// import 'package:homy/models/chat/chat_user.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/repositories/chat_repository.dart';
import 'package:homy/screens/chat_screen/controllers/chat_controller.dart';
import 'package:homy/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as path;
import '../../../services/websocket_service.dart';
import '../../../services/chat_storage_service.dart';
import '../../../services/config_service.dart';

class ChatScreenController extends GetxController {
  // List<ChatMessages> chatList = [];
  List<int?> deletedChatList = [];
  List<int> propertyIdsList = [];
  ChatListItem conversation;
  UserData? savedUser;
  UserData? conversationUser;
  List<ChatConversation> chatMessageslist = [];
  List<ChatMessages> chatMessages = [];
  bool isLoadingMessages = false;

  static String notificationUserId = '';

  TextEditingController textMessageController = TextEditingController();
  TextEditingController sendMediaController = TextEditingController();
  ScrollController scrollController = ScrollController();

  ScrollController propertyScrollController = ScrollController();

  int deletedId = 0;

  int screen;
  bool isBlock = false;
  bool isDeletedMsg = false;
  Function(int blockUnBlock)? onUpdateUser;

  ChatScreenController(this.conversation, this.screen, this.onUpdateUser);

  ChatMessages? replyToMessage;
  bool isReplying = false;

  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  Timer? _typingTimer;

  final ChatRepository _chatRepository = ChatRepository();

  final ChatStorageService _storageService = ChatStorageService();
  StreamSubscription? _messageUpdateSubscription;
  StreamSubscription? _messageUpdateFromServerSubscription;
  final AuthService _authService = Get.find<AuthService>();
  final configService = Get.find<ConfigService>();

  // Add new property
  bool isTyping = false;

  bool _isPageActive = true;

  // Media size limits in MB
  static const double _imageSizeLimit = 10.0;
  static const double _documentSizeLimit = 25.0;
  static const double _videoSizeLimit = 50.0;
  static const double _audioSizeLimit = 10.0;

  
  // Message types
  static const String _imageMessageType = '2';
  static const String _documentMessageType = '3';
  static const String _videoMessageType = '4';
  static const String _audioMessageType = 'audio';

  // Add message queue for incoming WebSocket messages
  final List<ChatMessages> _messageQueue = [];
  bool _hasLoadedInitialMessages = false;

  // Add new properties for message queue
  final List<ChatMessages> _pendingMessages = [];
  bool _isInitialLoadComplete = false;

  // Helper method to check file size and show error if needed
  Future<bool> _checkFileSize(
      XFile? file, double sizeLimit, String mediaType) async {
    if (file == null) return false;

    try {
      double sizeInMb;

      if (kIsWeb) {
        // Web platform
        final bytes = await file.length();
        sizeInMb = bytes / (1024 * 1024);
      } else {
        // Mobile platform
        final fileObj = File(file.path);
        sizeInMb = fileObj.lengthSync() / (1024 * 1024);
      }

      if (sizeInMb > sizeLimit) {
        Get.snackbar(
          'Error',
          '$mediaType size should be less than ${sizeLimit}MB',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
      return true;
    } catch (e) {
      print('Error checking file size: $e');
      Get.snackbar(
        'Error',
        'Unable to process $mediaType',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Media handling methods
  Future<void> handleImageSelection(XFile? image) async {
    if (image != null) {
      if (!await _checkFileSize(image, configService.config.value?.uploadConfig.maxImageUploadSize ?? 10.0, 'Image')) return;

      final messagelist = ChatMessages(
        text: textMessageController.text.trim(),
        fromId: _authService.id,
        toId: int.tryParse(conversation.user.userId) ?? 0,
        status: 'pending',
        uniqueId: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'image',
        media: image.path,
        time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );

      chatMessages.insert(0, messagelist);

      update();

      final response = await _chatRepository.sendOnlyImageMessage(
        param: {
          'user_id': conversation.user.userId.toString(),
          'message': textMessageController.text,
          'unique_id': DateTime.now().millisecondsSinceEpoch.toString(),
        },
        filesMap: {
          'sendMessageFile': [image!],
        },
      );
      textMessageController.clear();

      chatMessages.insert(0, response);
      update();

      Map<String, dynamic> message = {
        'type': 'media_message',
        'payload': ChatMessages.fromJson(response.toJson())
      };
      _webSocketService.sendMediaMessage(message);

      await _storageService.addNewMessage(
          conversation.user.userId.toString(), response);
    }
  }

  void handleDocumentSelection(XFile? document) async {
    if (!await _checkFileSize(document, configService.config.value?.uploadConfig.maxDocumentUploadSize ?? 25.0, 'Document')) return;

    await uploadFileGivePathApi(
      file: document!,
      messageType: _documentMessageType,
      message: null,
    );
  }

  void handleVideoSelection(XFile? video) async {
    if (!await _checkFileSize(video, configService.config.value?.uploadConfig.maxVideoUploadSize ?? 10.0, 'Video')) return;

    await uploadFileGivePathApi(
      file: video!,
      messageType: _videoMessageType,
      message: null,
    );
  }

  void handleAudioSelection(XFile? audio) async {
    if (!await _checkFileSize(audio, configService.config.value?.uploadConfig.maxAudioUploadSize ?? 10.0, 'Audio')) return;

    Get.log('handleAudioSelection');

    await uploadFileGivePathApi(
      file: audio!,
      messageType: _audioMessageType,
      message: null,
    );
  }

  // Upload file method
  Future<void> uploadFileGivePathApi({
    required XFile file,
    required String messageType,
    String? message,
  }) async {
    final messagelist = ChatMessages(
      text: textMessageController.text.trim(),
      fromId: _authService.id,
      toId: int.tryParse(conversation.user.userId) ?? 0,
      status: 'pending',
      uniqueId: DateTime.now().millisecondsSinceEpoch.toString(),
      type: messageType,
      media: file.path,
      time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    chatMessages.insert(0, messagelist);

    update();

    final response = await _chatRepository.sendOnlyImageMessage(
      param: {
        'user_id': conversation.user.userId.toString(),
        'message': textMessageController.text,
        'unique_id': DateTime.now().millisecondsSinceEpoch.toString(),
      },
      filesMap: {
        'sendMessageFile': [file],
      },
    );
    textMessageController.clear();

    chatMessages.insert(0, response);
    update();

    Map<String, dynamic> message = {
      'type': 'media_message',
      'payload': ChatMessages.fromJson(response.toJson())
    };
    _webSocketService.sendMediaMessage(message);

    await _storageService.addNewMessage(
        conversation.user.userId.toString(), response);

    // try {

    //   // Show loading indicator
    //   Get.dialog(
    //     const Center(child: CircularProgressIndicator()),
    //     barrierDismissible: false,
    //   );

    //   // Create form data for upload
    //   final formData = FormData({
    //     'file': await MultipartFile(file.path, filename: file.name),
    //     'message_type': messageType.toString(),
    //     if (message != null) 'message': message,
    //   });

    //   // Upload file using your API service
    //   // TODO: Replace with your actual API endpoint and service
    //   // final response = await apiService.uploadFile(formData);

    //   // Close loading dialog
    //   Get.back();

    //   // Create and send chat message
    //   final chatMessage = ChatMessages(
    //     time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    //     fromId: _authService.id,
    //     toId: int.tryParse(conversation.user.userId) ?? 0,
    //     status: 'pending',
    //     type: 'text',
    //     uniqueId: DateTime.now().millisecondsSinceEpoch.toString(),
    //     // TODO: Add media URL from response
    //     // mediaUrl: response.fileUrl,

    //   );

    //   // Add message to chat
    //   chatMessages.insert(0, chatMessage);
    //   update();

    //   // Save to storage
    //   await _storageService.addNewMessage(
    //     conversation.user.userId.toString(),
    //     chatMessage
    //   );

    //   // Send through WebSocket
    //   await _webSocketService.sendMessage(chatMessage);

    // } catch (e) {
    //   // Close loading dialog
    //   Get.back();

    //   Get.snackbar(
    //     'Error',
    //     'Failed to upload file: ${e.toString()}',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // }
  }

  @override
  void onReady() {
    notificationUserId = conversation.user.userId.toString();
    _loadData();
    super.onReady();
  }

  void _loadData() async {
    await fetchChatMessage();
    checkargument();
    update();
  }

  void checkargument() async {
    // Check if property message was passed as argument
    if (Get.arguments != null && Get.arguments is PropertyMessage) {
      PropertyMessage propertyMessage = Get.arguments as PropertyMessage;

      // Create chat message with property card
      final chatMessage = ChatMessages(
          time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          fromId: _authService.id,
          toId: int.tryParse(conversation.user.userId) ?? 0,
          status: 'pending',
          type: 'property',
          uniqueId: DateTime.now().millisecondsSinceEpoch.toString(),
          propertyId: propertyMessage.propertyId,
          property: propertyMessage,
          text: propertyMessage.message);

      // Add message to chat
      chatMessages.insert(0, chatMessage);
      update();

      // Save to storage and send via WebSocket
      _storageService.addNewMessage(
          conversation.user.userId.toString(), chatMessage);

      try {
        // Send message through WebSocket
        await _webSocketService.sendMessage(chatMessage);

        // If successful, update status to 'sent' in both UI and storage
        final msgIndex =
            chatMessages.indexWhere((msg) => msg.time == chatMessage.time);
        if (msgIndex != -1) {
          final updatedMessage = ChatMessages.fromJson(
              {...chatMessage.toJson(), 'status': 'sent'});

          chatMessages[msgIndex] = updatedMessage;

          await _storageService.updateMessageStatus(
              conversationId: conversation.user.userId.toString(),
              uniqueId: chatMessage.uniqueId.toString(),
              status: 'sent',
              messageId: '0',
              message: chatMessage);

          // Update conversation with sent status
          final finalConversation = ChatListItem.fromJsonStorage({
            ...conversation.toJson(),
            'last_message': updatedMessage.toJson(),
          });
          conversation = finalConversation;

          // Update chat list with sent status
          final chatList = await _storageService.getChatList();
          final chatIndex = chatList.indexWhere((chat) =>
              chat.user.userId.toString() ==
              conversation.user.userId.toString());

          if (chatIndex != -1) {
            chatList[chatIndex] = finalConversation;
            await _storageService.saveChatList(chatList);

            // Notify chat list screen about status update
            ChatStorageService.messageUpdateController
                .add(conversation.user.userId.toString());
          }

          update();
        }
      } catch (e) {
        print('Error sending message: $e');
        // Message remains as pending in UI and storage
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    _isPageActive = true;
    _setupWebSocket();
    _setupConnectionListener();
    _setupMessageUpdateListener();
    // _setupMessageUpdateFromServerListener();
    // Reset unread count when opening conversation
    if (conversation.lastMessage != null) {
      Get.find<MessageScreenController>()
          .resetUnreadCount(conversation.user.userId.toString());

      // Set this conversation as active
      MessageScreenController.setActiveConversation(
          conversation.user.userId.toString());
    }
  }

  void _setupMessageUpdateListener() {
    _messageUpdateSubscription = ChatStorageService.messageUpdates.listen(
      (conversationId) {
        if (conversationId == conversation.user.userId.toString()) {
          Get.log('Received message update for conversation: $conversationId');
          refreshCachedMessage();
        }
      },
      cancelOnError: true,
      onDone: () {
        Get.log('Message update stream completed');
        _messageUpdateSubscription?.cancel();
        _messageUpdateSubscription = null;
      },
      onError: (error) {
        Get.log('Error in message update stream: $error');
        _messageUpdateSubscription?.cancel();
        _messageUpdateSubscription = null;
      }
    );
  }

  void _setupMessageUpdateFromServerListener() {
    // _messageUpdateFromServerSubscription = ChatStorageService.messageFromServer.listen(
    //   (conversationId) {
    //     if (conversationId == conversation.user.userId.toString()) {
    //       Get.log('Received message update for conversation: ${int.parse(conversationId)+1}');
    //       fetchChatMessage();
    //     }
    //   },
    //   cancelOnError: true,
    //   onDone: () {
    //     Get.log('Message update stream completed');
    //     _messageUpdateFromServerSubscription?.cancel();
    //     _messageUpdateFromServerSubscription = null;
    //   },
    //   onError: (error) {
    //     Get.log('Error in message update stream: $error');
    //     _messageUpdateFromServerSubscription?.cancel();
    //     _messageUpdateFromServerSubscription = null;
    //   }
    // );
  }

  void _setupWebSocket() {
    final webSocketService = Get.find<WebSocketService>();

    webSocketService.onMessageReceived = _handleNewMessage;
    webSocketService.onTypingStatusChanged = _handleTypingStatus;
    webSocketService.onMessageStatusChanged = _handleMessageStatus;

    // Listen to connection state changes
    webSocketService.connectionState.listen((isConnected) {
      if (isConnected) {
        print('Connected to WebSocket');
      } else {
        print('Disconnected from WebSocket');
      }
    });
    _webSocketService.sendConversationOpen(conversation.user.userId.toString());
  }

  Future<void> _handleNewMessage(ChatMessages message) async {
    if (!_isPageActive) return;

    if (message.fromId.toString() == conversation.user.userId.toString()) {
      isTyping = false;
      update();
      _webSocketService.sendMessageStatus(
          message.uniqueId.toString(), 'Read', message.fromId.toString());

      // If we haven't loaded initial messages yet, queue this message
      if (!_hasLoadedInitialMessages) {
        _messageQueue.add(message);
        return;
      }

      // Add message to current chat if it doesn't exist
      if (!chatMessages.any((m) => m.time == message.time)) {
        // Ensure message is added in chronological order
        final insertIndex = chatMessages.indexWhere((m) => (m.time ?? 0) < (message.time ?? 0));
        if (insertIndex == -1) {
          chatMessages.add(message);
        } else {
          chatMessages.insert(insertIndex, message);
        }

        _storageService.updateMessageStatus(
            conversationId: conversation.user.userId.toString(),
            uniqueId: message.uniqueId.toString(),
            status: 'read',
            messageId: message.fromId.toString(),
            message: message);

        // Update the conversation's last message
        final updatedConversation = ChatListItem.fromJsonStorage({
          ...conversation.toJson(),
          'message': message.toJson(),
          'chat_time': message.time ?? 0,
        });
        conversation = updatedConversation;

        // Update chat list in storage
        final chatList = await _storageService.getChatList();
        final index = chatList.indexWhere((chat) =>
            chat.user.userId.toString() == conversation.user.userId.toString());

        if (index != -1) {
          chatList.removeAt(index);
          chatList.insert(0, updatedConversation); // Move to top
          await _storageService.saveChatList(chatList);

          // Notify chat list screen about the update
          ChatStorageService.messageUpdateController
              .add(conversation.user.userId.toString());
        }

        update();
      }
    }
  }

  Future<void> refreshCachedMessage() async {
    final cachedMessages =
        await _storageService.getMessages(conversation.user.userId.toString());
    if (cachedMessages.isNotEmpty) {
      chatMessages = cachedMessages;
    }
    update();
  }

  Future<void> fetchChatMessage() async {
    if (isLoadingMessages) return;
    isLoadingMessages = true;

    final String conversationId = conversation.user.userId.toString();

    try {
      // Load cached messages first
      final cachedMessages = await _storageService.getMessages(conversationId);
      if (cachedMessages.isNotEmpty) {
        // Sort cached messages by time
        cachedMessages.sort((a, b) => (b.time ?? 0).compareTo(a.time ?? 0));
        chatMessages = cachedMessages.take(100).toList();
        update();
      }

      // Get last delivered message timestamp
      final lastMessageTime = await _storageService.getLastMessageTimestamp(conversationId);
      final compareTime = lastMessageTime;

      // Prepare pagination parameters only if there are existing messages with valid IDs
      Map<String, dynamic>? params;
      if (chatMessages.isNotEmpty) {
        // Find the first message with a non-zero ID
        final messageWithId = chatMessages.firstWhere(
          (msg) => msg.id != null && msg.id! > 0 && msg.status == 'read',
          orElse: () => ChatMessages(),
        );
        
        if (messageWithId.id != null) {
          params = {
            'after_message_id': messageWithId.id.toString(),
          };
        }
      }
      
      // Fetch new messages from server with pagination
      chatMessageslist = await _chatRepository.getChatMessage(conversationId, params: params);


      if (chatMessageslist.isNotEmpty) {
        final newMessages = chatMessageslist.first.messages;


        // Sort new messages by time
        newMessages.sort((a, b) => (b.time ?? 0).compareTo(a.time ?? 0));

        // If we have a compare time, only add newer messages
        if (compareTime != null) {




            final newerMessages = newMessages.where((newMsg) {
              // Mark previous sent messages as read when new message is received
              // _markPreviousSentMessagesAsReadComprehensive(conversationId, newMessage: newMsg);
              if (newMsg.seen != 0) {
                try {
                  final firstSentIndex = chatMessages.indexWhere((msg) =>
                      msg.uniqueId == newMsg.uniqueId &&
                      msg.status?.toLowerCase() == 'sent');

                  if (firstSentIndex != -1) {
                    chatMessages[firstSentIndex] = ChatMessages.fromJson({
                      ...chatMessages[firstSentIndex].toJson(),
                      'status': 'read',
                      'seen': chatMessages[firstSentIndex].seen ?? 1
                    });
                    _storageService.saveMessages(conversationId, chatMessages);
                    update();
                  }
                } catch (e) {
                  Get.log('Error updating message status: $e');
                }
              }


            if ((newMsg.time ?? 0) <= compareTime) return false;


            return !chatMessages.any((existingMsg) {
              if (existingMsg.uniqueId == null || newMsg.uniqueId == null) return false;
              
              try {
                final existingUniqueId = int.tryParse(existingMsg.uniqueId!) ?? 0;
                final newUniqueId = int.tryParse(newMsg.uniqueId!) ?? 0;
                return existingUniqueId >= newUniqueId;
              } catch (e) {
                Get.log('Error parsing uniqueId: $e');
                return false;
              }
            });
          }).toList();

          if (newerMessages.isNotEmpty) {
            

            // Merge new messages with existing ones while maintaining order
            final allMessages = [...chatMessages, ...newerMessages];

            allMessages.sort((a, b) => (b.time ?? 0).compareTo(a.time ?? 0));
            chatMessages = allMessages.take(100).toList();

            // Update last delivered time
            final lastDeliveredMsg = newerMessages.firstWhere(
                (msg) => msg.status == 'delivered' || msg.status == 'read',
                orElse: () => ChatMessages());

            if (lastDeliveredMsg.time != null) {
              await _storageService.saveLastDeliveredTime(
                  conversationId, lastDeliveredMsg.time!);
            }


            // Save updated messages to storage
            await _storageService.saveMessages(conversationId, chatMessages);
            
            // Mark previous sent messages as read if last message is also read
            // _markPreviousSentMessagesAsReadComprehensive(conversationId);
            
            update();
          }
        } else {
          // For initial load, merge and sort all messages
          final allMessages = [...chatMessages, ...newMessages];
          allMessages.sort((a, b) => (b.time ?? 0).compareTo(a.time ?? 0));
          chatMessages = allMessages.take(100).toList();

          // Save initial messages
          await _storageService.saveMessages(conversationId, chatMessages);
          
          // Mark previous sent messages as read if last message is also read
          // _markPreviousSentMessagesAsReadComprehensive(conversationId);
          
          // Update last delivered time
          final lastDeliveredMsg = newMessages.firstWhere(
              (msg) => msg.status == 'delivered' || msg.status == 'read',
              orElse: () => ChatMessages());

          if (lastDeliveredMsg.time != null) {
            await _storageService.saveLastDeliveredTime(
                conversationId, lastDeliveredMsg.time!);
          }

          update();
        }
      }

      // Mark initial loading as complete
      _isInitialLoadComplete = true;
      _hasLoadedInitialMessages = true;

      // Process any pending messages
      if (_pendingMessages.isNotEmpty) {
        for (final pendingMessage in _pendingMessages) {

          final existingIndex = chatMessages.indexWhere((msg) => 
              msg.uniqueId == pendingMessage.uniqueId);
          
          if (existingIndex != -1) {
            // Update existing message with pending message status

            var messagetoUpdate = chatMessages[existingIndex];
            await _storageService.addNewMessage(
                conversation.user.userId.toString(), messagetoUpdate);
     
          } else {
            // Add new message to storage
            var messagetoUpdate = pendingMessage;
               await _storageService.addNewMessage(
              conversation.user.userId.toString(), messagetoUpdate);

          }
        }
        _pendingMessages.clear();
        update();
      }

      // Process any queued messages
      if (_messageQueue.isNotEmpty) {
        for (final queuedMessage in _messageQueue) {
          await _handleNewMessage(queuedMessage);
        }
        _messageQueue.clear();
      }

    } catch (e) {
      print('Error fetching messages: $e');
      if (chatMessages.isEmpty) {
        chatMessages = (await _storageService.getMessages(conversationId)).take(100).toList();
        update();
      }
    } finally {
      isLoadingMessages = false;
    }
  }

  void _handleTypingStatus(userId, bool typing) {
    if (!_isPageActive) return;

    print('Typing status: $typing');
    if (userId == conversation.user.userId.toString()) {
      isTyping = typing;
      update();
    }
  }

  void _handleMessageStatus(String messageId, String status) {
    // final messageIndex = chatList.indexWhere((m) => m.timeId.toString() == messageId);
    // if (messageIndex != -1) {
    //   chatList[messageIndex].status = status;
    //   update();
    // }
  }

  String generateMessageId() {
    int timestamp =
        DateTime.now().millisecondsSinceEpoch; // Current time in milliseconds
    int randomNumber = Random().nextInt(1000000); // Random number (0-999999)
    int randomNumber2 = Random().nextInt(2000000);
    return '$randomNumber2-$randomNumber'; // Combine device ID, timestamp, and random number
  }

  void getUserListListener() {
    // userListener = dSender
    //     ?.withConverter(
    //       fromFirestore: (snapshot, options) => Conversation.fromJson(snapshot.data()!),
    //       toFirestore: (Conversation value, options) {
    //         return value.toJson();
    //       },
    //     )
    //     .snapshots()
    //     .listen((event) {
    //   if (event.data() != null) {
    //     conversation = event.data()!;
    //     update();
    //   }
    // });
  }

  void getChat() {
    // dSender
    //     ?.withConverter(
    //       fromFirestore: (snapshot, options) => Conversation.fromJson(snapshot.data()!),
    //       toFirestore: (Conversation value, options) => value.toJson(),
    //     )
    //     .get()
    //     .then((value) {
    //   deletedId = value.data()?.deletedId ?? 0;
    // });

    // chatStream = dChatMessage
    //     .where(FireRes.notDeletedIdentity, arrayContains: savedUser?.id)
    //     .where(FireRes.timeId, isGreaterThan: deletedId)
    //     .withConverter(
    //       fromFirestore: (snapshot, options) => Chat.fromJson(snapshot.data()!),
    //       toFirestore: (Chat value, options) => value.toJson(),
    //     )
    //     .orderBy(FireRes.timeId, descending: true)
    //     .limit(cFirebaseDocumentLimit)
    //     .snapshots()
    //     .listen((event) {
    //   for (var element in event.docChanges) {
    //     switch (element.type) {
    //       case DocumentChangeType.added:
    //         // log('Added');
    //         chatList.add(element.doc);
    //         chatList.sort(
    //           (a, b) {
    //             return b.id.compareTo(a.id);
    //           },
    //         );
    //         update();
    //         break;
    //       case DocumentChangeType.modified:
    //         // log('Modified');
    //         break;
    //       case DocumentChangeType.removed:
    //         // log('Remove');
    //         break;
    //     }
    //   }
    //   if (event.docs.isNotEmpty) {
    //     lastDocument = event.docs.last;
    //   }
    // });
  }

  // Chat Text Message

  void onTextFieldTap() {
    if (deletedChatList.isNotEmpty) {
      onDeleteMessageCancel();
    }
  }

  void onTextMsgSend() async {
    if (!_isPageActive) return;

    if (textMessageController.text.trim().isEmpty) return;

    final message = ChatMessages(
      time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      text: textMessageController.text.trim(),
      fromId: _authService.id,
      toId: int.tryParse(conversation.user.userId) ?? 0,
      replyId: replyToMessage?.id != null ? replyToMessage!.id : null,
      reply: replyToMessage?.toJson() != null ? [replyToMessage!.toJson()] : null,
      status: 'pending',
      uniqueId: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    // Add to UI immediately
    chatMessages.insert(0, message);
    replyToMessage = null;
    isReplying = false;
    update();

    // Only save to storage if initial load is complete
    if (_isInitialLoadComplete) {
      await _storageService.addNewMessage(
          conversation.user.userId.toString(), message);
    } else {
      // Add to pending messages queue
      _pendingMessages.add(message);
    }

    // Update conversation's last message
    final updatedConversation = ChatListItem.fromJsonStorage({
      ...conversation.toJson(),
      'message': message.toJson(),
      'chat_time': message.time ?? 0,
    });
    conversation = updatedConversation;

    // Update chat list only if initial load is complete
    if (_isInitialLoadComplete) {
      final chatList = await _storageService.getChatList();
      final index = chatList.indexWhere((chat) =>
          chat.user.userId.toString() == conversation.user.userId.toString());

      if (index != -1) {
        chatList.removeAt(index);
        chatList.insert(0, updatedConversation); // Move to top
        await _storageService.saveChatList(chatList);

        // Notify chat list screen
        ChatStorageService.messageUpdateController
            .add(conversation.user.userId.toString());
      }
    }

    textMessageController.clear();
    update();

    try {
      // Send message through WebSocket
      await _webSocketService.sendMessage(message);

      // If successful, update status to 'sent' in both UI and storage
      final msgIndex =
          chatMessages.indexWhere((msg) => msg.time == message.time);
      if (msgIndex != -1) {
        final updatedMessage =
            ChatMessages.fromJson({...message.toJson(), 'status': 'sent'});

        chatMessages[msgIndex] = updatedMessage;

        if (_isInitialLoadComplete) {
          await _storageService.updateMessageStatus(
              conversationId: conversation.user.userId.toString(),
              uniqueId: message.uniqueId.toString(),
              status: 'sent',
              messageId: '0',
              message: message);

          // Update conversation with sent status
          final finalConversation = ChatListItem.fromJsonStorage({
            ...conversation.toJson(),
            'last_message': updatedMessage.toJson(),
          });
          conversation = finalConversation;

          // Update chat list with sent status
          final chatList = await _storageService.getChatList();
          final chatIndex = chatList.indexWhere((chat) =>
              chat.user.userId.toString() == conversation.user.userId.toString());

          if (chatIndex != -1) {
            chatList[chatIndex] = finalConversation;
            await _storageService.saveChatList(chatList);

            // Notify chat list screen about status update
            ChatStorageService.messageUpdateController
                .add(conversation.user.userId.toString());
          }
        }

        update();
      }
    } catch (e) {
      print('Error sending message: $e');
      // Message remains as pending in UI and storage
    }
  }

  bool _isCurrentlyTyping = false;

  // void onTextFieldChanged(String value) {
  //   if (_typingTimer?.isActive ?? false) _typingTimer?.cancel();

  //   _webSocketService.sendTypingStatus(
  //     conversation.user.userId.toString(),
  //     true,
  //   );

  //   _typingTimer = Timer(const Duration(seconds: 2), () {
  //     _webSocketService.sendTypingStatus(
  //       conversation.user.userId.toString(),
  //       false,
  //     );
  //   });
  // }

  void onTextFieldChanged(String value) {
    if (!_isPageActive) return;

    // Cancel existing timer if any
    _typingTimer?.cancel();
    _typingTimer = null;

    if (!_isCurrentlyTyping) {
      _isCurrentlyTyping = true;
      _webSocketService.sendTypingStatus(
          conversation.user.userId.toString(), true);
    }

    _typingTimer = Timer(const Duration(milliseconds: 3000), () {
      if (_isPageActive) {
        _isCurrentlyTyping = false;
        _webSocketService.sendTypingStatus(
            conversation.user.userId.toString(), false);
      }
    });
  }

  void onSwipeToReply(ChatMessages message) {
    replyToMessage = message;
    isReplying = true;
    update();
  }

  void cancelReply() {
    replyToMessage = null;
    isReplying = false;
    update();
  }

  // Chat Plus Button

  void onPlusButtonClick() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // void selectItem(int index) async {
  //   // BottomSheet close
  //   Get.back();
  //   if (index == 1) {
  //     Get.bottomSheet(PropertyListSheet(
  //       data: propertyList,
  //       controller: propertyScrollController,
  //       fetchData: fetchProperty,
  //       onPropertySend: (data) {
  //         Get.back();
  //         Get.bottomSheet(
  //           SendPropertySheet(
  //             data: data,
  //             onSendBtnClick: (p0, p1) {
  //               Get.back();
  //               List<String> propertyImage = [];
  //               data.media?.forEach((element) {
  //                 if (element.mediaTypeId != 7) {
  //                   propertyImage.add(element.content ?? '');
  //                 }
  //               });
  //               PropertyMessage property = PropertyMessage(
  //                   title: data.title,
  //                   propertyId: data.id,
  //                   message: p1,
  //                   image: propertyImage,
  //                   address: data.address,
  //                   propertyType: data.propertyAvailableFor);
  //               sendFirebaseMessage(
  //                 messageType: 4,
  //                 propertyMessage: property,
  //                 message: p1,
  //               );
  //             },
  //           ),
  //           isScrollControlled: true,
  //         );
  //       },
  //     ));
  //   } else if (index == 2) {
  //     Get.bottomSheet(
  //       SelectMediaSheet(
  //         onTap: onSelectMedia,
  //       ),
  //     );
  //   } else if (index == 3) {
  //     try {
  //       picker
  //           .pickImage(
  //               source: ImageSource.camera,
  //               imageQuality: cQualityImage,
  //               maxHeight: cMaxHeightImage,
  //               maxWidth: cMaxWidthImage)
  //           .then((value) {
  //         if (value == null) return;
  //         sendMediaSheet(image: value, messageType: 2);
  //       });
  //     } catch (e) {
  //       CommonUI.snackBar(title: S.current.youNotAllowPhotoAccess);
  //     }
  //   } else {
  //     selectVideo(0);
  //   }
  // }

  // void selectVideo(int type) {
  //   picker
  //       .pickVideo(
  //           source: type == 1 ? ImageSource.gallery : ImageSource.camera, maxDuration: const Duration(minutes: 5))
  //       .then((value) {
  //     if (value == null) return;
  //     if (CommonFun.getSizeInMb(value) <= maximumVideoSizeInMb) {
  //       VideoThumbnail.thumbnailFile(
  //               video: value.path,
  //               imageFormat: ImageFormat.JPEG,
  //               quality: cQualityVideo,
  //               maxWidth: cMaxWidthVideo,
  //               maxHeight: cMaxHeightVideo)
  //           .then((v) {
  //         if (v != null) {
  //           sendMediaSheet(image: XFile(v), messageType: 3, video: value);
  //         }
  //       });
  //     } else {
  //       Get.dialog(
  //         ConfirmationDialog(
  //           title1: S.current.tooLargeVideo,
  //           title2: AppRes.thisVideoIsGreaterThanEtc,
  //           onPositiveTap: () {
  //             Get.back();
  //             selectVideo(type);
  //           },
  //           aspectRatio: 1 / 0.5,
  //         ),
  //       );
  //     }
  //   });
  // }

  // void onSelectMedia(int index) {
  //   Get.back();
  //   if (index == 1) {
  //     picker
  //         .pickImage(
  //             source: ImageSource.gallery,
  //             imageQuality: cQualityImage,
  //             maxHeight: cMaxHeightImage,
  //             maxWidth: cMaxWidthImage)
  //         .then((value) {
  //       if (value == null) return;
  //       sendMediaSheet(image: value, messageType: 2);
  //     });
  //   } else {
  //     selectVideo(1);
  //   }
  // }

  // void sendMediaSheet({required XFile image, required int messageType, XFile? video}) {
  //   Get.bottomSheet(
  //           SendMediaSheet(
  //             image: image.path,
  //             onSendBtnClick: () => uploadFileGivePathApi(
  //                 image: image, messageType: messageType, video: video, message: sendMediaController.text.trim()),
  //             sendMediaController: sendMediaController,
  //           ),
  //           isScrollControlled: true)
  //       .then((value) {
  //     sendMediaController.clear();
  //   });
  // }

  // void uploadFileGivePathApi({required XFile image, required int messageType, XFile? video, String? message}) async {
  //   Get.back();
  //   CommonUI.loader();
  //   if (video != null) {
  //     ApiService().multiPartCallApi(
  //       url: UrlRes.uploadFileGivePath,
  //       filesMap: {
  //         uUploadFile: [video]
  //       },
  //       completion: (response) {
  //         UploadFile f = UploadFile.fromJson(response);
  //         if (f.status == true) {
  //           uploadFile(image: image, messageType: messageType, video: f.data, message: message);
  //         }
  //       },
  //     );
  //   } else {
  //     uploadFile(image: image, messageType: messageType, message: message);
  //   }
  // }

  // void uploadFile({
  //   required XFile image,
  //   required int messageType,
  //   String? video,
  //   String? message,
  // }) {
  //   ApiService().multiPartCallApi(
  //     url: UrlRes.uploadFileGivePath,
  //     filesMap: {
  //       uUploadFile: [image]
  //     },
  //     completion: (response) {
  //       Get.back();
  //       UploadFile f = UploadFile.fromJson(response);
  //       if (f.status == true) {
  //         sendFirebaseMessage(messageType: messageType, imageMessage: f.data, message: message, videoMessage: video);
  //       }
  //     },
  //   );
  // }

  // Chat Report And Block

  // void onMoreBtnClick(
  //   int index,
  //   ChatUser? userData,
  // ) {
  //   int userId = userData?.userID ?? -1;

  //   if (index == 0) {
  //     // Report
  //     if (userData != null) {
  //       Get.to(
  //         () => ReportScreen(
  //           reportUserData: UserData(
  //             id: userData.userID,
  //             fullname: userData.name,
  //             profile: userData.image,
  //             email: userData.identity,
  //             userType: userData.userType,
  //           ),
  //           reportType: ReportType.user,
  //         ),
  //       );
  //     } else {
  //       CommonUI.snackBar(title: S.current.userNotFound);
  //     }
  //   } else {
  //     //Block Unblock
  //     if (userId == -1) {
  //       CommonUI.snackBar(title: S.current.userIdNotFound);
  //       return;
  //     }

  //     Get.dialog(
  //       ConfirmationDialog(
  //         aspectRatio: 2.1,
  //         positiveText: conversation.iAmBlocked == true ? S.current.unblock : S.current.block,
  //         title1: AppRes.blockUnblockTitle(isBlock: conversation.iAmBlocked == true, name: conversation.user?.name),
  //         title2: AppRes.blockUnblockMessage(isBlock: conversation.iAmBlocked == true, name: conversation.user?.name),
  //         onPositiveTap: () {
  //           Get.back();
  //           List<String> blockId = savedUser?.blockUserIds?.split(',') ?? [];
  //           String blockUserIds = savedUser?.blockUserIds ?? '';
  //           if (blockUserIds.isEmpty) {
  //             blockUserIds = userId.toString();
  //           } else {
  //             if (blockId.contains(userId.toString())) {
  //               blockId.remove(userId.toString());
  //             } else {
  //               blockId.add(userId.toString());
  //             }
  //             blockUserIds = blockId.join(',');
  //           }

  //           CommonUI.loader();
  //           ApiService().multiPartCallApi(
  //             url: UrlRes.editProfile,
  //             filesMap: {},
  //             param: {
  //               uUserId: PrefService.id.toString(),
  //               uBlockUserIds: blockUserIds,
  //             },
  //             completion: (response) async {
  //               Get.back();
  //               FetchUser result = FetchUser.fromJson(response);
  //               if (result.status == true) {
  //                 savedUser = result.data;
  //                 if ((savedUser?.blockUserIds?.split(',') ?? []).contains(conversation.user?.userID.toString())) {
  //                   isBlock = true;
  //                   blockUnblockUserFirebase(status: true);
  //                 } else {
  //                   isBlock = false;
  //                   blockUnblockUserFirebase(status: false);
  //                 }
  //                 update();
  //                 await prefService.saveUser(result.data);
  //                 CommonUI.snackBar(
  //                     title: !isBlock
  //                         ? AppRes.unblockSnackBarMessage(name: conversation.user?.name)
  //                         : AppRes.blockSnackBarMessage(name: conversation.user?.name));
  //               } else {
  //                 CommonUI.snackBar(title: result.message.toString());
  //               }
  //             },
  //           );
  //         },
  //       ),
  //     );
  //   }
  // }

  // void blockUnblockUserFirebase({required bool status}) {
  //   dSender?.get().then((value) {
  //     if (value.exists) {
  //       dSender?.update({FireRes.iAmBlocked: status});
  //       dReceiver?.update({FireRes.iBlocked: status});
  //       onUpdateUser?.call(status ? 1 : 0);
  //     }
  //   });
  // }

  // Chat Delete

  onLongPressToDeleteChat(ChatMessages? message) {
    isDeletedMsg = true;
    if (!deletedChatList.contains(message?.time)) {
      deletedChatList.add(message?.time);
    } else {
      deletedChatList.remove(message?.time);
    }
    update();
  }

  // void onDeleteBtnClick() async {
  //   // for dialog dismiss
  //   Get.back();
  //   for (int i = 0; i < deletedChatList.length; i++) {
  //     chatList.removeWhere(
  //       (element) => int.parse(element.id) == deletedChatList[i],
  //     );
  //     dChatMessage.doc('${deletedChatList[i]}').update({
  //       FireRes.notDeletedIdentity: FieldValue.arrayRemove([savedUser?.id])
  //     });
  //   }
  //   isDeletedMsg = false;
  //   update();
  //   deletedChatList = [];
  // }

  void onDeleteMessageCancel() {
    isDeletedMsg = false;
    deletedChatList = [];
    update();
  }

  void fetchScrollProperties() {
    // propertyScrollController.addListener(
    //   () {
    //     if (propertyScrollController.offset >= propertyScrollController.position.maxScrollExtent) {
    //       if (!isPropertyFetching) {
    //         fetchMyPropertyApiCall();
    //       }
    //     }
    //   },
    // );
  }

  void _loadMoreData() {
    // Remove existing listener if any
    scrollController.removeListener(_scrollListener);
    // Add new listener
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      // fetchChatList();
    }
  }

  void _setupConnectionListener() {
    final webSocketService = Get.find<WebSocketService>();
    webSocketService.onConnectionStateChanged = (isConnected) {
      if (isConnected) {
        // Refresh chat list when connection is restored
        _refreshChatList();
      }
      update();
    };
  }

  Future<void> _refreshChatList() async {
    // Fetch latest chat list from storage
    final chatList = await _storageService.getChatList();

    // Update UI with latest chat list
    if (chatList.isNotEmpty) {
      // Find the current conversation in the updated list
      final updatedConversation = chatList.firstWhere(
          (chat) => chat.user.userId == conversation.user.userId,
          orElse: () => conversation);

      print('updatedConversation: ${updatedConversation.toJson()}');

      // Update the current conversation with latest data
      conversation = updatedConversation;

      // Refresh messages for current conversation
      await fetchChatMessage();

      update();
    }
  }

  void onReplyTap(ChatMessages message) {
    Get.log('Replied to message: ${message.toJson()}');
    replyToMessage = message;
    isReplying = true;
    update();
  }

  /// Marks previous sent messages as read when a new message is received
  void _markPreviousSentMessagesAsRead(ChatMessages newMessage, String conversationId) {
    try {
      // Only process if the new message is from the other user (not from current user)
      if (newMessage.fromId != null && newMessage.fromId != conversation.user.userId) {
        bool hasUpdates = false;
        
        // Optimized: Find and update sent messages in a single pass
        for (int i = 0; i < chatMessages.length; i++) {
          final msg = chatMessages[i];
          
          // Check if message is sent by current user and has 'sent' status
          if (msg.fromId == conversation.user.userId && 
              msg.status?.toLowerCase() == 'sent' &&
              msg.time != null && 
              newMessage.time != null &&
              msg.time! < newMessage.time!) {
            
            // Update the message to read status
            chatMessages[i] = ChatMessages.fromJson({
              ...chatMessages[i].toJson(),
              'status': 'read',
              'seen': chatMessages[i].seen ?? 1
            });
            hasUpdates = true;
          }
        }
        
        // Save and update if there were changes
        if (hasUpdates) {
          _storageService.saveMessages(conversationId, chatMessages);
          update();
        }
      }
    } catch (e) {
      Get.log('Error marking previous sent messages as read: $e');
    }
  }

  /// Marks previous sent messages as read when the last message is also read
  void _markPreviousSentMessagesAsReadWhenLastRead(String conversationId) {
    try {
      if (chatMessages.isEmpty) return;
      
      // Find the last message (assuming messages are sorted by time desc)
      final lastMessage = chatMessages.first;
      
      // If the last message is read and from the other user, mark all previous sent messages as read
      if (lastMessage.fromId != conversation.user.userId && 
          lastMessage.status?.toLowerCase() == 'read') {
        
        bool hasUpdates = false;
        
        // Optimized: Find and update sent messages in a single pass
        for (int i = 0; i < chatMessages.length; i++) {
          final msg = chatMessages[i];
          
          // Check if message is sent by current user and has 'sent' status
          if (msg.fromId == conversation.user.userId && 
              msg.status?.toLowerCase() == 'sent') {
            
            // Update the message to read status
            chatMessages[i] = ChatMessages.fromJson({
              ...chatMessages[i].toJson(),
              'status': 'read',
              'seen': chatMessages[i].seen ?? 1
            });
            hasUpdates = true;
          }
        }
        
        // Save and update if there were changes
        if (hasUpdates) {
          _storageService.saveMessages(conversationId, chatMessages);
          update();
        }
      }
    } catch (e) {
      Get.log('Error marking previous sent messages as read when last read: $e');
    }
  }

  /// Marks all previous sent messages as read (utility function)
  void markAllPreviousSentMessagesAsRead(String conversationId) {
    try {
      bool hasUpdates = false;
      
      // Optimized: Find and update sent messages in a single pass
      for (int i = 0; i < chatMessages.length; i++) {
        final msg = chatMessages[i];
        
        // Check if message is sent by current user and has 'sent' status
        if (msg.fromId == conversation.user.userId && 
            msg.status?.toLowerCase() == 'sent') {
          
          // Update the message to read status
          chatMessages[i] = ChatMessages.fromJson({
            ...chatMessages[i].toJson(),
            'status': 'read',
            'seen': chatMessages[i].seen ?? 1
          });
          hasUpdates = true;
        }
      }
      
      // Save and update if there were changes
      if (hasUpdates) {
        _storageService.saveMessages(conversationId, chatMessages);
        update();
      }
    } catch (e) {
      Get.log('Error marking all previous sent messages as read: $e');
    }
  }

  /// Comprehensive function to mark previous sent messages as read
  /// Handles both scenarios: new message received and last message read
  void _markPreviousSentMessagesAsReadComprehensive(String conversationId, {ChatMessages? newMessage}) {
    try {
      bool hasUpdates = false;
      
      // Determine the condition for marking messages as read
      bool shouldMarkAsRead = false;
      
      if (newMessage != null) {
        // Scenario 1: New message received from other user
        shouldMarkAsRead = newMessage.fromId != null && 
                          newMessage.fromId != conversation.user.userId;
      } else {
        // Scenario 2: Check if last message is read and from other user
        if (chatMessages.isNotEmpty) {
          final lastMessage = chatMessages.first;
          shouldMarkAsRead = lastMessage.fromId != conversation.user.userId && 
                            lastMessage.status?.toLowerCase() == 'read';
        }
      }
      
      if (!shouldMarkAsRead) return;
      
      // Optimized: Find and update sent messages in a single pass
      for (int i = 0; i < chatMessages.length; i++) {
        final msg = chatMessages[i];
        
        // Check if message is sent by current user and has 'sent' status
        if (msg.fromId == conversation.user.userId && 
            msg.status?.toLowerCase() == 'sent') {
          
          // For new message scenario, only mark messages older than the new message
          if (newMessage != null && 
              msg.time != null && 
              newMessage.time != null &&
              msg.time! >= newMessage.time!) {
            continue;
          }
          
          // Update the message to read status
          chatMessages[i] = ChatMessages.fromJson({
            ...chatMessages[i].toJson(),
            'status': 'read',
            'seen': chatMessages[i].seen ?? 1
          });
          hasUpdates = true;
        }
      }
      
      // Save and update if there were changes
      if (hasUpdates) {
        _storageService.saveMessages(conversationId, chatMessages);
        update();
      }
    } catch (e) {
      Get.log('Error in comprehensive mark previous sent messages as read: $e');
    }
  }

  // Add dispose method for cleanup
  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  void _cleanupResources() {
    // Dispose controllers
    textMessageController.dispose();
    sendMediaController.dispose();
    scrollController.dispose();
    propertyScrollController.dispose();

    // Cancel and nullify timer
    _typingTimer?.cancel();
    _typingTimer = null;

    // Cancel subscriptions
    _messageUpdateSubscription?.cancel();
    _messageUpdateSubscription = null;
    _messageUpdateFromServerSubscription?.cancel();
    _messageUpdateFromServerSubscription = null;

    // Clear large lists
    chatMessages.clear();
    chatMessageslist.clear();
    deletedChatList.clear();
    propertyIdsList.clear();
  }

  // Update onClose to include cleanup
  @override
  void onClose() {
    _isPageActive = false;
    _hasLoadedInitialMessages = false;
    _isInitialLoadComplete = false;
    _messageQueue.clear();
    _pendingMessages.clear();

    // Cancel typing status if active
    if (_isCurrentlyTyping) {
      _webSocketService.sendTypingStatus(
          conversation.user.userId.toString(), false);
      _isCurrentlyTyping = false;
    }

    // Cancel any pending timers
    _typingTimer?.cancel();
    _typingTimer = null;

    // Remove message update subscription
    _messageUpdateSubscription?.cancel();
    _messageUpdateFromServerSubscription?.cancel();

    // Remove WebSocket listeners
    final webSocketService = Get.find<WebSocketService>();
    webSocketService.onConnectionStateChanged = null;
    webSocketService.onMessageReceived = null;
    webSocketService.onTypingStatusChanged = null;
    webSocketService.onMessageStatusChanged = null;

    // Clear active conversation if it's this one
    if (MessageScreenController.activeConversationId ==
        conversation.user.userId.toString()) {
      MessageScreenController.setActiveConversation(null);
    }

    // Cleanup resources
    _cleanupResources();

    super.onClose();
  }
}
