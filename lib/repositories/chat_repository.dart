import 'package:homy/models/chat/chat_list.dart';
import 'package:homy/models/chat/chat_message.dart';
import 'package:homy/utils/constants.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/api_client.dart';

class ChatRepository {
  // Singleton instance
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);


  // ApiClient get apiClient {
  //   final authService = Get.find<AuthService>();
  //   final client = ApiClient(appBaseUrl: Constants.baseUrl);
  //   client.updateHeader(
  //     authService.token,
  //     null, null, null, null, null, null,
  //   );
  //   return client;
  // }


  // Get conversations for the current user
  Future<List<ChatListItem>> getConversations() async {
    try {
      final response = await apiClient.getData(
        'chats',
      );

      if (response.statusCode == 200) {
            // final List<dynamic> chatListData = response.body['data'];
        // return chatListData.map((data) => ChatListItem.fromJson(data)).toList();
      return response.body['data'].map<ChatListItem>((obj) => ChatListItem.fromJson(obj)).toList();

          } else {
        throw Exception('Failed to Chat List: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Failed to Chat List: $e');
    }
   
  }
  Future<List<ChatConversation>> getChatMessage(String conversationId, {Map<String, dynamic>? params}) async {
    try{
      final response = await apiClient.getData('chats/$conversationId', query: params,handleError: false);
            return [ChatConversation.fromJson(response.body['data'])];

      // return response.body['data'].map<ChatConversation>((obj) => ChatConversation.fromJson(obj)).toList();
    }
    catch(e){
      throw Exception('Failed to Retrive Chat Message: $e');
    }
    
  }


  Future<void> sendMessage({
    required Map<String, String> param,
    required XFile? filesMap,
    Function(double)? onProgress,
  }) async {
    try {

        final response = await apiClient.postMultipartData(
      'chats/1', param,prepareMultipart(filesMap,null),
      );
 if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw Exception('Failed to send message: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }





  Future<ChatMessages> sendOnlyImageMessage({
  required Map<String, dynamic> param,
    required Map<String, List<XFile>> filesMap,
  }) async {
    try {

        final response = await apiClient.multiPartRequestWeb(
      url: 'chats/${param['user_id']}',
      fields: param,
      filesMap: filesMap,
      );

 if (response.statusCode == 200) {
        return ChatMessages.fromJson(response.body['data']['messages']);
      } else {
        throw Exception('Failed to send message: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }



  List<MultipartBody> prepareMultipart(XFile? pickedImage, List<XFile>? pickedIdentities) {
    List<MultipartBody> multiParts = [];
    multiParts.add(MultipartBody('sendMessageFile', pickedImage));
    if(pickedIdentities != null) {
      for(XFile file in pickedIdentities) {
        multiParts.add(MultipartBody('identity_image[]', file));
      }
    }
    return multiParts;
  }

  // Send a message
  Future<void> sendMessage1({
    required String receiverId,
    required String message,
    String? attachmentUrl,
  }) async {
    try {
      // TODO: Implement API call to send message
      // This is where you would make an API call to your backend
    } catch (e) {
      throw 'Could not send message';
    }
  }

  // Get messages for a specific conversation
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      // TODO: Implement API call to fetch messages
      // This is where you would make an API call to your backend
      return [];
    } catch (e) {
      throw 'Could not fetch messages';
    }
  }

  // Mark conversation as read
  Future<void> markAsRead(String conversationId) async {
    try {
      // TODO: Implement API call to mark conversation as read
      // This is where you would make an API call to your backend
    } catch (e) {
      throw 'Could not mark conversation as read';
    }
  }

  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // TODO: Implement API call to delete conversation
      // This is where you would make an API call to your backend
    } catch (e) {
      throw 'Could not delete conversation';
    }
  }
}

// Message model class
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String? attachmentUrl;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.attachmentUrl,
    required this.timestamp,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      attachmentUrl: json['attachmentUrl'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }



}