class Earning {
  final int id;
  final int tourId;
  final double amount;
  final double serviceFee;
  final double agentEarning;
  final double platformEarning;
  final String status;
  final DateTime? processedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime tourDate;
  final String tourTime;

  Earning({
    required this.id,
    required this.tourId,
    required this.amount,
    required this.serviceFee,
    required this.agentEarning,
    required this.platformEarning,
    required this.status,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.tourDate,
    required this.tourTime,
  });

  factory Earning.fromJson(Map<String, dynamic> json) {
    return Earning(
      id: json['id'] as int,
      tourId: json['tour_id'] as int,
      amount: double.parse(json['amount'].toString()),
      serviceFee: double.parse(json['service_fee'].toString()),
      agentEarning: double.parse(json['agent_earning'].toString()),
      platformEarning: double.parse(json['platform_earning'].toString()),
      status: json['status'] as String,
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tourDate: DateTime.parse(json['tour_date']),
      tourTime: json['tour_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tour_id': tourId,
      'amount': amount.toString(),
      'service_fee': serviceFee.toString(),
      'agent_earning': agentEarning.toString(),
      'platform_earning': platformEarning.toString(),
      'status': status,
      'processed_at': processedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tour_date': tourDate.toIso8601String().split('T')[0],
      'tour_time': tourTime,
    };
  }
}

class EarningResponse {
  final List<Earning> data;
  final Pagination pagination;

  EarningResponse({
    required this.data,
    required this.pagination,
  });

  factory EarningResponse.fromJson(Map<String, dynamic> json) {
    return EarningResponse(
      data: (json['data'] as List)
          .map((e) => Earning.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int totalPages;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
    );
  }
} 