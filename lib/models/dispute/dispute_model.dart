import 'package:homy/models/dispute/dispute_message.dart';

class Evidence {
  final int id;
  final String content;
  final String thumbnail;
  final int mediaTypeId;
  final DateTime createdAt;
  final int propertyId;

  Evidence({
    required this.id,
    required this.content,
    required this.thumbnail,
    required this.mediaTypeId,
    required this.createdAt,
    required this.propertyId,
  });

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      id: json['id'],
      content: json['content'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      mediaTypeId: json['media_type_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? ''),
      propertyId: json['property_id'] ?? 0,
    );
  }
}

class Property {
  final String name;
  final int propertyId;
  final String image;

  Property({
    required this.name,
    required this.propertyId,
    required this.image,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      name: json['name'] ?? '',
      propertyId: json['property_id'] ?? 0,
      image: json['image'] ?? '',
    );
  }
}

class Participant {
  final int id;
  final String name;
  final String? email;
  final String? avatar;

  Participant({
    required this.id,
    required this.name,
    this.email,
    this.avatar,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'],
      avatar: json['avatar'],
    );
  }
}

class Participants {
  final Participant? initiatedBy;
  final Participant? disputedAgainst;
  final Participant? agent;
  final Participant? user;

  Participants({
     this.initiatedBy,
     this.disputedAgainst,
     this.agent,
     this.user,
  });

  factory Participants.fromJson(Map<String, dynamic> json) {
    return Participants(
      initiatedBy: json['initiated_by'] != null ? Participant.fromJson(json['initiated_by']) : null,
      disputedAgainst: json['disputed_against'] != null ? Participant.fromJson(json['disputed_against']) : null,
      agent: json['agent'] != null ? Participant.fromJson(json['agent']) : null,
      user: json['user'] != null ? Participant.fromJson(json['user']) : null,
    );
  }
}

class Payment {
  final double amount;

  Payment({required this.amount});

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(amount: double.parse(json['amount'].toString()));
  }
}

class Dispute {
  final int? id;
  final int? tourId;
  final int? paymentId;
  final String? status;
  final String? reason;
  final List<Evidence>? evidence;
  final String? adminNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final Property? property;
  final Participants? participants;
  final Payment? payment;
  final List<DisputeMessage>? history;

  Dispute({
     this.id,
     this.tourId,
     this.paymentId,
     this.status,
     this.reason,
     this.evidence,
    this.adminNotes,
     this.createdAt,
     this.updatedAt,
    this.resolvedAt,
     this.property,
     this.participants,
     this.payment,
     this.history,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: json['id'],
      paymentId: json['payment_id'],
      tourId: json['tour_id'],  
      status: json['status']??'',
      reason: json['reason'] ?? '',
      // evidence: json['evidence'] != null ? (json['evidence'] as List<dynamic>).map((e) => Evidence.fromJson(e)).toList() : [],
      adminNotes: json['admin_notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      resolvedAt: json['resolved_at'] != null 
          ? DateTime.parse(json['resolved_at'])
          : null,
      property: json['property'] != null ? Property.fromJson(json['property']) : null,
      participants: json['participants'] != null ? Participants.fromJson(json['participants']) : null,
      payment: json['payment'] != null ? Payment.fromJson(json['payment']) : null,
      history: json['history'] != null ? (json['history'] as List<dynamic>).map((e) => DisputeMessage.fromJson(e)).toList() : [],
    );
  }
} 