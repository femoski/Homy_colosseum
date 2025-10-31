class ChatUsers {
   String userId;
   String? firstName;
   String? lastName;
   String username;
   String email;
   String avatar;
   String name;

  ChatUsers({
    required this.userId,
    this.firstName,
    this.lastName,
    required this.username,
    required this.email,
    required this.avatar,
    required this.name,
  });

  factory ChatUsers.fromJson(Map<String, dynamic> json) {
    return ChatUsers(
      userId: json['user_id']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
    'email': email,
    'avatar': avatar,
    'name': name,
    // 'is_online': isOnline,
  };
}

class ChatMessage {
  final int id;
  final int fromId;
  final int toId;
  final String text;
  final String media;
  final int time;
  final String timeText;
  final int seen;
  final bool read;
  final ChatUsers messageUser;
  final int owner;
  final int unreadCount;
  final String status;
  final String type;
  ChatMessage({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.text,
    required this.media,
    required this.time,
    required this.timeText,
    required this.seen,
    required this.read,
    required this.messageUser,
    required this.owner,
    required this.unreadCount,
    required this.status,
    required this.type,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toInt() ?? 0,
      fromId: json['from_id']?.toInt() ?? 0,
      toId: json['to_id']?.toInt() ?? 0,
      text: json['text']?.toString() ?? '',
      media: json['media']?.toString() ?? '',
      time: json['time']?.toInt() ?? 0,
      timeText: json['time_text']?.toString() ?? '',
      seen: json['seen']?.toInt() ?? 0,
      read: json['read'] == 'yes' || json['read'] == true,
      messageUser: ChatUsers.fromJson(json['messageUser'] ?? {}),
      owner: json['owner']?.toInt() ?? 0,
      unreadCount: json['unread_count']?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      type: json['type']?.toString() ?? 'chat',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'from_id': fromId,
    'to_id': toId,
    'text': text,
    'media': media,
    'time': time,
    'time_text': timeText,
    'seen': seen,
    'read': read ? 'yes' : 'no',
    'messageUser': messageUser.toJson(),
    'owner': owner,
    'unread_count': unreadCount,
    'status': status,
    'type': type,
  };
}

class ChatListItem {
  final ChatUsers user;
  final int chatTime;
  final int unreadCount;
  ChatMessage? lastMessage;

  String? isOnline;
  int? lastSeen;
  bool isTyping;

  ChatListItem({
    required this.user,
    required this.chatTime,
    required this.unreadCount,
    this.lastMessage,
    required this.isTyping,
    this.isOnline,
    this.lastSeen
  });

  factory ChatListItem.fromJson(Map<String, dynamic> json) {
    return ChatListItem(
      user: ChatUsers.fromJson(json),
      chatTime: json['chat_time']?.toInt() ?? 0,
      lastMessage: ChatMessage.fromJson(json['message'] ?? {}),
      unreadCount: json['unread_count']?.toInt() ?? 0,
      isOnline: json['is_online'] ?? 'offline',
      lastSeen: json['lastseen'] ?? 0,
      isTyping: json['is_typing'] == 'yes' || json['is_typing'] == true,
    );
  }

    factory ChatListItem.fromJsonStorage(Map<String, dynamic> json) {
    return ChatListItem(
      user: ChatUsers.fromJson(json['user'] ?? {}),
      chatTime: json['chat_time']?.toInt() ?? 0,
      lastMessage: ChatMessage.fromJson(json['message'] ?? {}),
      unreadCount: json['unread_count']?.toInt() ?? 0,
      isOnline: json['is_online'] ?? 'offline',
      lastSeen: json['lastseen'] ?? 0,
      isTyping: json['is_typing'] == 'yes' || json['is_typing'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'chat_time': chatTime,
    'message': lastMessage?.toJson(),
    'unread_count': unreadCount,
    'is_online': isOnline,
    'lastseen': lastSeen
  };
}
