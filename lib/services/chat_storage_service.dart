import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homy/models/chat/chat_list.dart';
import 'package:homy/models/chat/chat_message.dart';
import 'dart:async';

import 'package:homy/services/auth_service.dart';

class ChatStorageService {
  static const String _undeliveredMessagesKey = 'undelivered_messages';
  static const String _chatListKey = 'chat_list';
  static const String _messagesKey = 'chat_messages';
  static const String _lastDeliveredTimeKey = 'last_delivered_time';
  final _storage = GetStorage();
  static final messageUpdateController = StreamController<String>.broadcast();
  static Stream<String> get messageUpdates => messageUpdateController.stream;


  // static final messageUpdateFromServer = StreamController<String>.broadcast();
  // static Stream<String> get messageFromServer => messageUpdateFromServer.stream;


  static final userStatusUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get userStatusUpdates => userStatusUpdateController.stream;
  
  final authService = Get.find<AuthService>();
  
  Future<void> saveChatList(List<ChatListItem> chatList) async {
    final List<Map<String, dynamic>> serializedList = 
        chatList.map((chat) => chat.toJson()).toList();
    await _storage.write(_chatListKey, serializedList);
  }

  Future<List<ChatListItem>> getChatList() async {
    final List<dynamic>? data = _storage.read(_chatListKey);

    if (data == null) return [];
    return data.map((item) {
      print(item);
      return ChatListItem.fromJsonStorage(item);
    }).toList();
  }

  Future<void> saveUndeliveredMessage(ChatMessages message) async {
    List<Map<String, dynamic>> messages = await getUndeliveredMessages();
    messages.add(message.toJson());
    await _storage.write(_undeliveredMessagesKey, messages);
  }

  Future<List<Map<String, dynamic>>> getUndeliveredMessages() async {
    final List<dynamic>? data = _storage.read(_undeliveredMessagesKey);
    return (data ?? []).cast<Map<String, dynamic>>();
  }

  Future<void> removeUndeliveredMessage(int timeId) async {
    List<Map<String, dynamic>> messages = await getUndeliveredMessages();
    final removedMessage = messages.firstWhere(
      (msg) => msg['time'] == timeId,
      orElse: () => <String, dynamic>{},
    );
    messages.removeWhere((msg) => msg['time'] == timeId);

    await _storage.write(_undeliveredMessagesKey, messages);
    
    // Update message status in conversation if message was found
    if (removedMessage.isNotEmpty) {
      final conversationId = removedMessage['to_id'].toString();
      
      // Update message in conversation
      final List<ChatMessages> conversationMessages = await getMessages(conversationId);
      final index = conversationMessages.indexWhere((m) => m.time == timeId);
      if (index != -1) {
        final updatedMessage = ChatMessages.fromJson({
          ...conversationMessages[index].toJson(),
          'status': 'sent'
        });
        conversationMessages[index] = updatedMessage;
        await saveMessages(conversationId, conversationMessages);
      }

      // Update chat list item's last message status
      final chatList = await getChatList();
      final chatIndex = chatList.indexWhere((chat) => chat.user.userId == conversationId);

      print('chatIndex: ${chatList[chatIndex].toJson()}');
      if (chatIndex != -1 && chatList[chatIndex].lastMessage?.time == timeId) {
        final updatedChatItem = ChatListItem.fromJsonStorage({
          ...chatList[chatIndex].toJson(),
          'last_message': {
            ...chatList[chatIndex].lastMessage!.toJson(),
            'status': 'sent'
          }
        });
        chatList[chatIndex] = updatedChatItem;
        await saveChatList(chatList);
      }

      // Broadcast the update
      messageUpdateController.add(conversationId);
    }
  }

  Future<void> clearUndeliveredMessages() async {
    await _storage.write(_undeliveredMessagesKey, []);
  }

  Future<void> saveMessages(String conversationId, List<ChatMessages> messages) async {
    final String key = '${_messagesKey}_$conversationId';
    
    messages.sort((a, b) => (b.time ?? 0).compareTo(a.time ?? 0));
    
    final undeliveredMessages = await getUndeliveredMessages();
    
    final List<Map<String, dynamic>> serializedMessages = messages.map((message) {
      final Map<String, dynamic> messageJson = message.toJson();
      
      if (message.fromId == int.parse(authService.id.toString())) {
        final isUndelivered = undeliveredMessages.any((m) => m['time'] == message.time);
        messageJson['status'] = isUndelivered ? 'pending' : (messageJson['status'] ?? 'sent');
      }
      
      return messageJson;
    }).toList();
    
    await _storage.write(key, serializedMessages);
  }

  Future<List<ChatMessages>> getMessages(String conversationId) async {
    final String key = '${_messagesKey}_$conversationId';
    final List<dynamic>? data = _storage.read(key);
    
    if (data == null) return [];
    
    return data.map((item) => ChatMessages.fromJson(item)).toList();
  }

  Future<void> addNewMessage(String conversationId, ChatMessages message) async {
    // Add message to conversation messages
    List<ChatMessages> messages = await getMessages(conversationId);
    messages.insert(0, message);
    messages.sort((a, b) => (b.time ?? 0).compareTo(a.time ?? 0));
    await saveMessages(conversationId, messages);
    
    // Update chat list with new message
    final chatList = await getChatList();
    final chatIndex = chatList.indexWhere((chat) => 
      chat.user.userId.toString() == conversationId
    );
    
    if (chatIndex != -1) {
      final existingChat = chatList[chatIndex];
      final updatedChatItem = ChatListItem.fromJsonStorage({
        ...existingChat.toJson(),
        'last_message': message.toJson(),
        'chat_time': message.time ?? 0,
      });
      
      // Move conversation with new message to top
      chatList.removeAt(chatIndex);
      chatList.insert(0, updatedChatItem);
      await saveChatList(chatList);
      
      // Notify listeners about the update
    }
          messageUpdateController.add(conversationId);

  }

  // Future<void> updateMessageStatus(String conversationId, int messageTime, String status) async {
  //   final messages = await getMessages(conversationId);
  //   final index = messages.indexWhere((msg) => msg.time == messageTime);
    
  //   if (index != -1) {
  //     messages[index] = ChatMessages.fromJson({
  //       ...messages[index].toJson(),
  //       'status': status,
  //       'id': messages[index].uniqueId
  //     });
  //     await saveMessages(conversationId, messages);
  //   }
  // }

  Future<int?> getLastMessageTimestamp(String conversationId) async {
    final messages = await getMessages(conversationId);
    if (messages.isEmpty) return null;
    
    // Return raw epoch timestamp for direct comparison
    return messages.first.time;
  }

  Future<void> saveLastDeliveredTime(String conversationId, int timestamp) async {
    final String key = '${_lastDeliveredTimeKey}_$conversationId';
    await _storage.write(key, timestamp);
  }

  Future<int?> getLastDeliveredTime(String conversationId) async {
    final String key = '${_lastDeliveredTimeKey}_$conversationId';
    return _storage.read<int>(key);
  }

  Future<void> addUndeliveredMessage(Map<String, dynamic> message) async {
    List<Map<String, dynamic>> messages = await getUndeliveredMessages();
    messages.add(message);
    await _storage.write(_undeliveredMessagesKey, messages);
    
    // Also update the message status in the conversation messages
    final conversationId = message['conversationId'];
    final List<ChatMessages> conversationMessages = await getMessages(conversationId);
    
    final index = conversationMessages.indexWhere((m) => m.time == message['time']);
    if (index != -1) {
      final updatedMessage = ChatMessages.fromJson({
        ...conversationMessages[index].toJson(),
        'status': 'pending'
      });
      conversationMessages[index] = updatedMessage;
      await saveMessages(conversationId, conversationMessages);
    }
  }

  Future<void> updateMessageStatus({required String conversationId, required String uniqueId, required String status, required String messageId, required ChatMessages message}) async {
   
    final messages = await getMessages(conversationId);

    final index = messages.indexWhere((msg) => msg.uniqueId == uniqueId);
    if (index != -1) {

    if(status != 'status_update'){

      if(messages[index].status == 'read'){
        return;
      }
      
      messages[index] = ChatMessages.fromJson({
        ...messages[index].toJson(),
        'status': status,
      });     
    }
    else{
      messages[index] = ChatMessages.fromJson({
        ...messages[index].toJson(),
        ...message.toJson()
      });
    }
      await saveMessages(conversationId, messages);
      

      // Broadcast the update
       messageUpdateController.add(conversationId);
    }
  }

  Future<void> updateUserStatus(String userId, String status) async {
    // final String key = '${_userStatusKey}_$userId';
    // await _storage.write(key, status);
    userStatusUpdateController.add({
      'user_id': userId,
      'status': status
    });
  }

    Future<void> updateOpenConversation(String conversationId) async {
   
    final messages = await getMessages(conversationId);

    // Find the range of sent messages to optimize iteration
    int startIndex = messages.length - 1;
    int endIndex = 0;
    
    // Find the last occurrence of 'sent' status
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].status == 'sent') {
        startIndex = i;
        break;
      }
    }
    
    // Find the first occurrence of 'sent' status
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].status == 'sent') {
        endIndex = i;
        break;
      }
    }
        print('Update begin here: ${startIndex} - ${endIndex}');

    // Update only the range containing 'sent' messages
    if (startIndex >= endIndex) {
      for (int i = endIndex; i <= startIndex; i++) {
        if (messages[i].status == 'sent') {
          messages[i] = ChatMessages.fromJson({
            ...messages[i].toJson(),
            'status': 'read',
          });
        }
      }
    }

      await saveMessages(conversationId, messages);
      // Broadcast the update
       messageUpdateController.add(conversationId);
    
  }

  Future<ChatListItem?> getConversationById(String conversationId) async {
    final List<ChatListItem> chatList = await getChatList();
    return chatList.firstWhereOrNull((chat) => 
      chat.user.userId.toString() == conversationId
    );
  }

  static void dispose() {
    messageUpdateController.close();
    userStatusUpdateController.close();
  }
} 
