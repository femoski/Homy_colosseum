import 'package:intl/intl.dart';

class NotificationModel {
  final int id;
  final int? userId;
  final String title;
  final String message;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isRead;
  final bool isDeleted;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.updatedAt,
    this.isRead = false,
    this.isDeleted = false,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      title: json['title'] as String? ?? '',
      message: json['description'] as String? ?? '', // API uses 'description' not 'message'
      createdAt: _parseDateTime(json['createdAt'] as String? ?? json['notification_created_at'] as String?),
      updatedAt: _parseDateTime(json['updatedAt'] as String?),
      isRead: json['is_read'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }


  static DateTime _parseDateTime(String? dateString) {
    if (dateString == null) return DateTime.now();
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_read': isRead,
      'is_deleted': isDeleted,
      'data': data,
    };
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRead,
    bool? isDeleted,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted ?? this.isDeleted,
      data: data ?? this.data,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(createdAt);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get shortMessage {
    if (message.length <= 60) return message;
    return '${message.substring(0, 60)}...';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, isRead: $isRead)';
  }
}

class NotificationResponse {
  final List<NotificationModel> data;
  final NotificationMeta meta;

  const NotificationResponse({
    required this.data,
    required this.meta,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      data: (json['data']['notifications'] as List<dynamic>)
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: NotificationMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

class NotificationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const NotificationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
    };
  }

  bool get hasMore => page < totalPages;
}
