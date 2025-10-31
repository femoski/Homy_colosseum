import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/chat/chat_list.dart';
import 'package:homy/repositories/chat_repository.dart';
import '../../../models/chat/chat_message.dart';
import '../../../services/chat_storage_service.dart';
import 'package:get_storage/get_storage.dart';

import '../../../services/websocket_service.dart';

class MessageScreenController extends GetxController {
  final ChatStorageService _storageService = ChatStorageService();
  final searchController = TextEditingController();
  List<ChatListItem> allUserList = [];
  List<ChatListItem> filteredUserList = [];
  bool isLoading = true;
  final ChatRepository _chatRepository = ChatRepository();
  StreamSubscription? _messageUpdateSubscription;
  StreamSubscription? _userStatusUpdateSubscription;

  static String? activeConversationId;
  
  String? get activeChatId => activeConversationId;

  @override
  void onInit() {
    super.onInit();
    // loadChatListFromCache();
    _setupMessageUpdateListener();
    _setupWebSocket();
  }

  void _setupWebSocket() {
    final webSocketService = Get.find<WebSocketService>();

    webSocketService.onMessageReceived = _handleNewMessage;
    // webSocketService.onTypingStatusChanged = _handleTypingStatus;
    // webSocketService.onMessageStatusChanged = _handleMessageStatus;
  }

  Future<void> _handleNewMessage(ChatMessages message) async {
    // Update chat list in storage
    final chatList = await _storageService.getChatList();
    final index = chatList.indexWhere(
        (chat) => chat.user.userId.toString() == message.fromId.toString());

    if (index != -1) {
      // Get current conversation data
      final currentConversation = chatList[index];

      // Calculate new unread count
      int unreadCount = currentConversation.unreadCount ?? 0;

      // Only increment unread count if:
      // 1. Message is from the conversation user
      // 2. The conversation is not currently active/open
      if (message.fromId.toString() == chatList[index].user.userId.toString() &&
          message.fromId.toString() != activeConversationId) {
        unreadCount += 1;
      }

      // Update the conversation's last message
      final updatedConversation = ChatListItem.fromJsonStorage({
        ...chatList[index].toJson(), // Keep existing conversation data
        'message': {
          ...message.toJson(),
          'unread_count': unreadCount, // Add updated unread count
        },
        'chat_time': message.time ?? 0,
      });

      print('updatedConversation: ${updatedConversation.toJson()}');

      chatList.removeAt(index);
      chatList.insert(0, updatedConversation); // Move to top
      await _storageService.saveChatList(chatList);

      // Update local lists if they exist
      if (allUserList.isNotEmpty) {
        final localIndex = allUserList.indexWhere(
            (chat) => chat.user.userId.toString() == message.fromId.toString());

        if (localIndex != -1) {
          allUserList.removeAt(localIndex);
          allUserList.insert(0, updatedConversation);

          // Update filtered list if needed
          final filteredIndex = filteredUserList.indexWhere((chat) =>
              chat.user.userId.toString() == message.fromId.toString());
          if (filteredIndex != -1) {
            filteredUserList.removeAt(filteredIndex);
            filteredUserList.insert(0, updatedConversation);
          }

          update();
        }
      }

      // Notify chat list screen about the update
      ChatStorageService.messageUpdateController.add(message.fromId.toString());
    }
  }

  void _setupMessageUpdateListener() {
    _messageUpdateSubscription =
        ChatStorageService.messageUpdates.listen((conversationId) {
      _updateConversationInList(conversationId);
    });

    _userStatusUpdateSubscription = ChatStorageService.userStatusUpdates.listen((data) {
      updateUserOnlineStatus(data['user_id'].toString(), data['status'].toString());
    });
  }

  Future<void> _updateConversationInList(String conversationId) async {
    final messages = await _storageService.getMessages(conversationId);
    if (messages.isEmpty) return;

try{
    final index = allUserList
        .indexWhere((chat) => chat.user.userId.toString() == conversationId);

    int unreadCount = allUserList[index].unreadCount ?? 0;

    if (messages.first.fromId.toString() ==
            allUserList[index].user.userId.toString() &&
        messages.first.fromId.toString() != activeConversationId) {
      // Count messages from this sender that are unread
      int senderMessageCount = messages.where((msg) => 
        msg.fromId.toString() == allUserList[index].user.userId.toString() &&
        msg.status != 'read'
      ).length;
      
      // Update unread count based on actual unread messages
      unreadCount = senderMessageCount;
    }
    
    if (index != -1) {
      final updatedChat = ChatListItem.fromJsonStorage({
        ...allUserList[index].toJson(),
        'message': messages.first.toJson(),
        'chat_time': messages.first.time ?? 0,
        'unread_count': unreadCount, // Add updated unread count
      });

      print('updatedChat: ${updatedChat.toJson()}');

      allUserList.removeAt(index);
      allUserList.insert(0, updatedChat);

      final filteredIndex = filteredUserList
          .indexWhere((chat) => chat.user.userId.toString() == conversationId);
      if (filteredIndex != -1) {
        filteredUserList.removeAt(filteredIndex);
        filteredUserList.insert(0, updatedChat);
      }
      await _storageService.saveChatList(allUserList);

      update();
    }
    }
    catch(e){
      await fetchFromServer();

      print('Error updating conversation in list: $e');
    }
  }

  Future<void> loadChatListFromCache() async {
    isLoading = true;
    update();

    try {
      final cachedList = await _storageService.getChatList();

      if (cachedList.isNotEmpty) {
        cachedList.sort((a, b) =>
            (b.lastMessage?.time ?? 0).compareTo(a.lastMessage?.time ?? 0));

        allUserList = List.from(cachedList);
        filteredUserList = List.from(cachedList);
        update();
      }

      if (cachedList.isEmpty || _shouldRefreshFromServer()) {
        await fetchFromServer();
      }
    } catch (e) {
      print('Error loading chat list from cache: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  bool _shouldRefreshFromServer() {
    final lastRefresh = GetStorage().read<int>('last_chat_list_refresh') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // return now - lastRefresh > 5 * 60 * 1000;
        return now - lastRefresh > 5*1000;

  }

  Future<void> fetchFromServer() async {
    try {
      final chatList = await _chatRepository.getConversations();

       _storageService.saveChatList(chatList);
       GetStorage().write(
          'last_chat_list_refresh', DateTime.now().millisecondsSinceEpoch);

      if (allUserList.isEmpty || _hasSignificantChanges(chatList)) {
        allUserList = List.from(chatList);
              filteredUserList = List.from(chatList);
  
      }
         filteredUserList = List.from(chatList);
        update();
    } catch (e) {
      print('Error fetching from server: $e');
    }
  }

  bool _hasSignificantChanges(List<ChatListItem> newList) {
    if (newList.length != allUserList.length) return true;

    for (var i = 0; i < 3 && i < newList.length; i++) {
      if (i >= allUserList.length) return true;

      final newChat = newList[i];
      final oldChat = allUserList[i];

      if (newChat.user.userId != oldChat.user.userId ||
          newChat.lastMessage?.time != oldChat.lastMessage?.time) {
        return true;
      }
    }
    return false;
  }

  @override
  void onClose() {
    _messageUpdateSubscription?.cancel();
    _userStatusUpdateSubscription?.cancel();
    super.onClose();
  }

  void onSearchUser(String value) {
    if (value.isEmpty) {
      filteredUserList = allUserList;
    } else {
      filteredUserList = allUserList
          .where((element) =>
              element.user?.name?.toLowerCase().contains(value.toLowerCase()) ??
              false)
          .toList();
    }
    update();
  }

  // Add a method to reset unread count when opening a conversation
  Future<void> resetUnreadCount(String conversationId) async {
    final chatList = await _storageService.getChatList();
    final index = chatList
        .indexWhere((chat) => chat.user.userId.toString() == conversationId);


    if (index != -1) {
      final updatedConversation = ChatListItem.fromJsonStorage({
        ...chatList[index].toJson(),
        'unread_count': 0,
      });

      chatList[index] = updatedConversation;
      await _storageService.saveChatList(chatList);

      // Update local lists
      final localIndex = allUserList
          .indexWhere((chat) => chat.user.userId.toString() == conversationId);
      if (localIndex != -1) {
        allUserList[localIndex] = updatedConversation;

        final filteredIndex = filteredUserList.indexWhere(
            (chat) => chat.user.userId.toString() == conversationId);
        if (filteredIndex != -1) {
          filteredUserList[filteredIndex] = updatedConversation;
        }

        update();
      }
    }
  }

  static void setActiveConversation(String? conversationId) {
    activeConversationId = conversationId;
  }

  void updateUserOnlineStatus(String userId, String isOnline)async {
    final index = filteredUserList.indexWhere((chat) => chat.user?.userId == userId);
    if (index != -1) {
      filteredUserList[index].isOnline = isOnline;
      await _storageService.saveChatList(filteredUserList);
      update();
    }
    
  }

}
