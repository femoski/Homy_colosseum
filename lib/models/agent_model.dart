class AgentModel {
  final String id;
  final String name;
  final String? image;
  final String? email;
  final String? phone;
  final int propertyCount;
  final String? description;
  final bool isVerified;
  final double rating;
  final int reviewCount;

  AgentModel({
    required this.id,
    required this.name,
    this.image,
    this.email,
    this.phone,
    required this.propertyCount,
    this.description,
    this.isVerified = false,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      image: json['image'],
      email: json['email'],
      phone: json['phone'],
      propertyCount: json['property_count'] ?? 0,
      description: json['description'],
      isVerified: json['is_verified'] ?? false,
      // rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'email': email,
      'phone': phone,
      'property_count': propertyCount,
      'description': description,
      'is_verified': isVerified,
      'rating': rating,
      'review_count': reviewCount,
    };
  }
}