import 'package:homy/models/chat/property_message.dart';

class ChatMessageUser {
  final int userId;
  final String name;
  final String avatar;

  ChatMessageUser({
    required this.userId,
    required this.name,
    required this.avatar,
  });

  factory ChatMessageUser.fromJson(Map<String, dynamic> json) {
    return ChatMessageUser(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'avatar': avatar,
    };
  }
}

class ChatReaction {
  final bool isReacted;
  final String type;
  final int count;

  ChatReaction({
    required this.isReacted,
    required this.type,
    required this.count,
  });

  factory ChatReaction.fromJson(Map<String, dynamic> json) {
    return ChatReaction(
      isReacted: json['is_reacted'] ?? false,
      type: json['type'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_reacted': isReacted,
      'type': type,
      'count': count,
    };
  }
}

class ChatMessages {
  final int? id;
  final int? fromId;
  final int? groupId;
  final int? pageId;
  final int? toId;
  final String? text;
  final String? media;
  final String? mediaFileName;
  final String? mediaFileNames;
  final int? time;
  final int? seen;
  final String? deletedOne;
  final String? deletedTwo;
  final int? sentPush;
  final String? notificationId;
  final String? typeTwo;
  final String? stickers;
  final int? propertyId;
  final String? lat;
  final String? lng;
  final int? replyId;
  final int? storyId;
  final int? broadcastId;
  final int? forward;
  final int? listening;
  final String? removeAt;
  final String? read;
  final String? bg;
  final String? deleteby;
  final String? lastby;
  final String? hidden;
  final String? groupSeen;
  final int? unsettledMsgId;
  final String? forwarded;
  final String? replied;
  final ChatMessageUser? messageUser;
  final PropertyMessage? property;
  final String? pin;
  final dynamic reply;
  final List<dynamic>? story;
  final ChatReaction? reaction;
  final String? position;
  final String? type;
  final String? timeText;
  final String? status;
  final String? uniqueId;


  ChatMessages({
    this.id,
     this.fromId,
     this.groupId,
     this.pageId,
     this.toId,
    this.text,
     this.media,
      this.mediaFileName,
      this.mediaFileNames,
      this.time,
      this.seen,
      this.deletedOne,
      this.deletedTwo,
     this.sentPush,
    this.notificationId,
    this.typeTwo,
    this.stickers,
    this.propertyId,
    this.lat,
    this.lng,
    this.replyId,
    this.storyId,
    this.broadcastId,
    this.forward,
    this.listening,
    this.removeAt,
    this.read,
    this.bg,
    this.deleteby,
    this.lastby,
    this.hidden,
    this.groupSeen,
    this.unsettledMsgId,
    this.forwarded,
    this.replied,
    this.messageUser,
    this.property,
    this.pin,
     this.reply,
    this.story,
    this.reaction,
    this.position,
    this.type,
    this.timeText,
    this.status,
    this.uniqueId,
  });

  factory ChatMessages.fromJson(Map<String, dynamic> json) {
    return ChatMessages(
      id: json['id'] ?? 0,
      fromId: json['from_id'] ?? 0,
      groupId: json['group_id'] ?? 0,
      pageId: json['page_id'] ?? 0,
      toId: json['to_id'] ?? 0,
      text: json['text'] ?? '',
      media: json['media'] ?? '',
      mediaFileName: json['mediaFileName'] ?? '',
      mediaFileNames: json['mediaFileNames'] ?? '',
      time: json['time'] ?? 0,
      seen: json['seen'] ?? 0,
      deletedOne: json['deleted_one'] ?? '0',
      deletedTwo: json['deleted_two'] ?? '0',
      sentPush: json['sent_push'] ?? 0,
      notificationId: json['notification_id'] ?? '',
      typeTwo: json['type_two'] ?? '',
      stickers: json['stickers'] ?? '',
      propertyId: json['property_id'] ?? 0,
      lat: json['lat'] ?? '0',
      lng: json['lng'] ?? '0',
      replyId: json['reply_id'] ?? 0,
      storyId: json['story_id'] ?? 0,
      broadcastId: json['broadcast_id'] ?? 0,
      forward: json['forward'] ?? 0,
      listening: json['listening'] ?? 0,
      removeAt: json['remove_at']?.toString() ?? '0',
      read: json['read'],
      bg: json['bg'],
      deleteby: json['deleteby'] ?? '',
      lastby: json['lastby'] ?? '0',
      hidden: json['hidden'],
      groupSeen: json['group_seen'],
      unsettledMsgId: json['unsettled_msg_id'],
      forwarded: json['forwarded'],
      replied: json['replied'] ?? '0',
      messageUser: json['messageUser'] != null 
          ? ChatMessageUser.fromJson(json['messageUser'])
          : null,
      property: json['property'] != null 
          ? PropertyMessage.fromJson(json['property'])
          : null,
      uniqueId: json['unique_id'],
      pin: json['pin'],
      reply: json['reply'] ?? [],
      story: json['story'] ?? [],
      reaction: json['reaction'] != null 
          ? ChatReaction.fromJson(json['reaction'])
          : null,
      position: json['position'] ?? 'right',
      type: json['type'] ?? 'text',
      timeText: json['time_text'] ?? '',
        status: json['status'],
    );
  }

   factory ChatMessages.ToJson(Map<String, dynamic> json) {
    return ChatMessages(
      id: json['id'],
      fromId: json['fromId'],
      groupId: json['groupId'],
      pageId: json['pageId'] ,
      toId: json['toId'],
      text: json['text'],
      media: json['media'],
      mediaFileName: json['mediaFileName'],
      mediaFileNames: json['mediaFileNames'],
      time: json['time'],
      seen: json['seen'],
      deletedOne: json['deletedOne'],
      deletedTwo: json['deletedTwo'],
      sentPush: json['sentPush'],
      notificationId: json['notificationId'],
      typeTwo: json['typeTwo'],
      stickers: json['stickers'],
      propertyId: json['propertyId'],
      lat: json['lat'],
      lng: json['lng'],
      replyId: json['replyId'],
      storyId: json['storyId'],
      broadcastId: json['broadcastId'],
      forward: json['forward'],
      listening: json['listening'],
      removeAt: json['removeAt'],
      read: json['read'],
      bg: json['bg'],
      deleteby: json['deleteby'],
      lastby: json['lastby'],
      hidden: json['hidden'],
      groupSeen: json['groupSeen'],
      unsettledMsgId: json['unsettledMsgId'],
      forwarded: json['forwarded'],
      replied: json['replied'],
      messageUser: ChatMessageUser.fromJson(json['messageUser'] ?? {}),
      property: json['property'] != null 
          ? PropertyMessage.fromJson(json['property'])
          : null,
      pin: json['pin'],
      reply: json['reply'] ?? [],
      story: json['story'] ?? [],
      reaction: ChatReaction.fromJson(json['reaction'] ?? {}),
      position: json['position'],
      type: json['type'],
      timeText: json['time_text'],
      status: json['status'],
      uniqueId: json['unique_id'],

    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['from_id'] = fromId;
    data['group_id'] = groupId;
    data['page_id'] = pageId;
    data['to_id'] = toId;
    data['text'] = text;
    data['media'] = media;
    data['mediaFileName'] = mediaFileName;
    data['mediaFileNames'] = mediaFileNames;
    data['time'] = time;
    data['seen'] = seen;
    data['deleted_one'] = deletedOne;
    data['deleted_two'] = deletedTwo;
    data['sent_push'] = sentPush;
    data['notification_id'] = notificationId;
    data['type_two'] = typeTwo;
    data['stickers'] = stickers;
    data['property_id'] = propertyId;
    data['lat'] = lat;
    data['lng'] = lng;
    data['reply_id'] = replyId;
    data['story_id'] = storyId;
    data['broadcast_id'] = broadcastId;
    data['forward'] = forward;
    data['listening'] = listening;
    data['remove_at'] = removeAt;
    data['read'] = read;
    data['bg'] = bg;
    data['deleteby'] = deleteby;
    data['lastby'] = lastby;
    data['hidden'] = hidden;
    data['group_seen'] = groupSeen;
    data['unsettled_msg_id'] = unsettledMsgId;
    data['forwarded'] = forwarded;
    data['replied'] = replied;
    if (messageUser != null) {
      data['messageUser'] = {
        'user_id': messageUser!.userId,
        'avatar': messageUser!.avatar,
      };
    }
    if (property != null) {
     data['property'] = property!.toJson();
    }
    data['pin'] = pin;
    data['reply'] = reply;
    data['story'] = story;
    if (reaction != null) {
      data['reaction'] = {
        'is_reacted': reaction!.isReacted,
        'type': reaction!.type,
        'count': reaction!.count,
      };
    }
    data['position'] = position;
    data['type'] = type;
    data['time_text'] = timeText;
    data['status'] = status;
    data['unique_id'] = uniqueId;
    return data;
  }
}

class ChatRecipient {
  final int id;
  final String name;
  final String avatar;

  ChatRecipient({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory ChatRecipient.fromJson(Map<String, dynamic> json) {
    return ChatRecipient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}

class ChatConversation {
  final List<ChatMessages> messages;
  final ChatRecipient recipient;

  ChatConversation({
    required this.messages,
    required this.recipient,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      messages: (json['messages'] as List? ?? [])
          .map((msg) => ChatMessages.fromJson(msg))
          .toList(),
      recipient: ChatRecipient.fromJson(json['recipient'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'recipient': recipient.toJson(),
    };
  }
} 