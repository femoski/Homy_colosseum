import 'package:intl/intl.dart';

class DisputeMessage {
  final DateTime timestamp;
  final String type;
  final String? senderType;
  final String? senderName;
  final String? senderAvatar;
  final String? content;
  final String? title;
  final MessageMetadata? metadata;

  DisputeMessage({
    required this.timestamp,
    required this.type,
    this.senderType,
    this.senderName,
    this.senderAvatar,
    this.content,
    this.title,
    this.metadata,
  });

  factory DisputeMessage.fromJson(Map<String, dynamic> json) {
    return DisputeMessage(
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      senderType: json['sender_type'],
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
      content: json['content'],
      title: json['title'],
      metadata: json['metadata'] != null ? MessageMetadata.fromJson(json['metadata']) : null,
    );
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(timestamp);
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

  bool get isMessage => type == 'message';
  bool get isTransfer => type == 'transfer';
  bool get isStatusChange => type == 'status_change';
}

class MessageMetadata {
  final String? amount;
  final String? action;
  final String? notes;
  final String? status;

  MessageMetadata({
    this.amount,
    this.action,
    this.notes,
    this.status,
  });

  factory MessageMetadata.fromJson(Map<String, dynamic> json) {
    return MessageMetadata(
      amount: json['amount']?.toString(),
      action: json['action'],
      notes: json['notes'],
      status: json['status'],
    );
  }
} 