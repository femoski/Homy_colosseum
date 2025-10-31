class TourRequestStatus {
  static const int waiting = 1;
  static const int confirmed = 1;
    static const int completed = 2;
  static const int declined = 3;
  static const int disputed = 4;
  static const int refunded = 5;
}

class DisputeStatus {
  static const int pending = 0;
  static const int resolvedForAgent = 1;
  static const int resolvedForUser = 2;
}

class TourRequest {
  final int id;
  final int propertyId;
  final int userId;
  final int agentId;
  final DateTime tourDate;
  final String tourTime;
  final int status;
  final bool userConfirmedComplete;
  final DateTime? completedAt;
  final DateTime? disputeOpenedAt;
  final int? disputeStatus;
  final String? disputeReason;
  final String? disputeEvidence;
  
  TourRequest({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.agentId,
    required this.tourDate,
    required this.tourTime,
    required this.status,
    required this.userConfirmedComplete,
    this.completedAt,
    this.disputeOpenedAt,
    this.disputeStatus,
    this.disputeReason,
    this.disputeEvidence,
  });

  factory TourRequest.fromJson(Map<String, dynamic> json) {
    return TourRequest(
      id: json['id'] as int,
      propertyId: json['property_id'] as int,
      userId: json['user_id'] as int,
      agentId: json['agent_id'] as int,
      tourDate: DateTime.parse(json['tour_date'] as String),
      tourTime: json['tour_time'] as String,
      status: json['status'] as int,
      userConfirmedComplete: json['user_confirmed_complete'] as bool,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      disputeOpenedAt: json['dispute_opened_at'] != null ? DateTime.parse(json['dispute_opened_at'] as String) : null,
      disputeStatus: json['dispute_status'] as int?,
      disputeReason: json['dispute_reason'] as String?,
      disputeEvidence: json['dispute_evidence'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'user_id': userId,
      'agent_id': agentId,
      'tour_date': tourDate.toIso8601String(),
      'tour_time': tourTime,
      'status': status,
      'user_confirmed_complete': userConfirmedComplete,
      'completed_at': completedAt?.toIso8601String(),
      'dispute_opened_at': disputeOpenedAt?.toIso8601String(),
      'dispute_status': disputeStatus,
      'dispute_reason': disputeReason,
      'dispute_evidence': disputeEvidence,
    };
  }
} 