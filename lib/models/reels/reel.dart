
// class Reel {
//   final String id;
//   final String userId;
//   final String videoUrl;
//   final String thumbnailUrl;
//   final String description;
//   final List<String> hashtags;
//   final String? propertyId;
//   final int likes;
//   final int comments;
//   final int shares;
//   final DateTime createdAt;

//   Reel({
//     required this.id,
//     required this.userId,
//     required this.videoUrl,
//     required this.thumbnailUrl,
//     required this.description,
//     required this.hashtags,
//     this.propertyId,
//     required this.likes,
//     required this.comments,
//     required this.shares,
//     required this.createdAt,
//   });

//   factory Reel.fromMap(Map<String, dynamic> map, String id) {
//     return Reel(
//       id: id,
//       userId: map['userId'] ?? '',
//       videoUrl: map['videoUrl'] ?? '',
//       thumbnailUrl: map['thumbnailUrl'] ?? '',
//       description: map['description'] ?? '',
//       hashtags: List<String>.from(map['hashtags'] ?? []),
//       propertyId: map['propertyId'],
//       likes: map['likes'] ?? 0,
//       comments: map['comments'] ?? 0,
//       shares: map['shares'] ?? 0,
//       createdAt: (map['createdAt'] as Timestamp).toDate(),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'userId': userId,
//       'videoUrl': videoUrl,
//       'thumbnailUrl': thumbnailUrl,
//       'description': description,
//       'hashtags': hashtags,
//       'propertyId': propertyId,
//       'likes': likes,
//       'comments': comments,
//       'shares': shares,
//       'createdAt': Timestamp.fromDate(createdAt),
//     };
//   }

//   Reel copyWith({
//     String? id,
//     String? userId,
//     String? videoUrl,
//     String? thumbnailUrl,
//     String? description,
//     List<String>? hashtags,
//     String? propertyId,
//     int? likes,
//     int? comments,
//     int? shares,
//     DateTime? createdAt,
//   }) {
//     return Reel(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       videoUrl: videoUrl ?? this.videoUrl,
//       thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
//       description: description ?? this.description,
//       hashtags: hashtags ?? this.hashtags,
//       propertyId: propertyId ?? this.propertyId,
//       likes: likes ?? this.likes,
//       comments: comments ?? this.comments,
//       shares: shares ?? this.shares,
//       createdAt: createdAt ?? this.createdAt,
//     );
//   }
// } 