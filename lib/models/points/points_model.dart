import 'package:get/get.dart';

enum PointsActivityType {
  profileCompletion,
  dailyLogin,
  propertyListing,
  propertyView,
  referral,
  referralPropertyListing,
  tourCompletion,
  reviewSubmission,
  socialShare
}

class PointsActivity {
  final PointsActivityType type;
  final int points;
  final String description;
  final String icon;

  const PointsActivity({
    required this.type,
    required this.points,
    required this.description,
    required this.icon,
  });

  factory PointsActivity.fromJson(Map<String, dynamic> json) {
    return PointsActivity(
      type: PointsActivityType.values.firstWhere(
        (e) => e.toString() == 'PointsActivityType.${json['type']}',
        orElse: () => PointsActivityType.dailyLogin,
      ),
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'star',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'points': points,
      'description': description,
      'icon': icon,
    };
  }
}

class PointsTransaction {
  final int id;
  final int points;
  final String description;
  final DateTime createdAt;
  final String type; // 'earned' or 'redeemed'
  final String? reference;
  final PointsActivityType? activityType;

  PointsTransaction({
    required this.id,
    required this.points,
    required this.description,
    required this.createdAt,
    required this.type,
    this.reference,
    this.activityType,
  });

  factory PointsTransaction.fromJson(Map<String, dynamic> json) {
    return PointsTransaction(
      id: json['id'] ?? 0,
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      type: json['type'] ?? 'earned',
      reference: json['reference'],
      activityType: json['activity_type'] != null
          ? PointsActivityType.values.firstWhere(
              (e) => e.toString() == 'PointsActivityType.${json['activity_type']}',
              orElse: () => PointsActivityType.dailyLogin,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'type': type,
      'reference': reference,
      'activity_type': activityType?.toString().split('.').last,
    };
  }
}

class PointsData {
  final int totalPoints;
  final int availablePoints;
  final int pendingPoints;
  final List<PointsTransaction> transactions;
  final List<PointsActivity> availableActivities;
  final Pagination pagination;

  PointsData({
    required this.totalPoints,
    required this.availablePoints,
    required this.pendingPoints,
    required this.transactions,
    required this.availableActivities,
    required this.pagination,
  });

  factory PointsData.fromJson(Map<String, dynamic> json) {
    return PointsData(
      totalPoints: json['total_points'] ?? 0,
      availablePoints: json['available_points'] ?? 0,
      pendingPoints: json['pending_points'] ?? 0,
      transactions: (json['transactions'] as List?)
              ?.map((t) => PointsTransaction.fromJson(t))
              .toList() ??
          [],
      availableActivities: (json['available_activities'] as List?)
              ?.map((a) => PointsActivity.fromJson(a))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_points': totalPoints,
      'available_points': availablePoints,
      'pending_points': pendingPoints,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'available_activities': availableActivities.map((a) => a.toJson()).toList(),
    };
  }
}

class PointsResponse {
  final PointsData data;
  final Pagination pagination;

  PointsResponse({
    required this.data,
    required this.pagination,
  });

  factory PointsResponse.fromJson(Map<String, dynamic> json) {
    return PointsResponse(
      data: PointsData.fromJson(json['data'] ?? {}),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? 0,
      itemsPerPage: json['items_per_page'] ?? 10,
    );
  }
} 