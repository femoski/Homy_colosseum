
// class Comment {
//   Comment({
//     bool? status,
//     String? message,
//     CommentData? data,
//   }) {
//     _status = status;
//     _message = message;
//     _data = data;
//   }

//   Comment.fromJson(dynamic json) {
//     _status = json['status'];
//     _message = json['message'];
//     _data = json['data'] != null ? CommentData.fromJson(json['data']) : null;
//   }

//   bool? _status;
//   String? _message;
//   CommentData? _data;

//   bool? get status => _status;

//   String? get message => _message;

//   CommentData? get data => _data;

//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['status'] = _status;
//     map['message'] = _message;
//     if (_data != null) {
//       map['data'] = _data?.toJson();
//     }
//     return map;
//   }
// }

import 'package:homy/models/users/fetch_user.dart';

class CommentData {
  CommentData({
    int? userId,
    int? reelId,
    String? description,
    String? updatedAt,
    String? createdAt,
    int? id,
    UserData? user,
    int? likesCount,
    bool? isLiked,
    bool? isOwner,
    bool? isReply,
    String? time,
    List<CommentData>? replies,
  }) {
    _userId = userId;
    _reelId = reelId;
    _description = description;
    _updatedAt = updatedAt;
    _createdAt = createdAt;
    _id = id;
    _user = user;
    _likesCount = likesCount;
    _isLiked = isLiked;
    _isOwner = isOwner;
    _isReply = isReply;
    _replies = replies;
    }

  CommentData.fromJson(dynamic json) {
    _userId = json['user_id'];
    _reelId = json['reel_id'];
    _description = json['description'];
    _updatedAt = json['time'].toString();
    _createdAt = json['time'].toString();
    _id = json['id'] ?? json['id']  ;
    _user = json['publisher'] != null ? UserData.fromJson(json['publisher']) : null;
    _likesCount = json['likes_count'];
    _isLiked = json['is_liked'];
    _isOwner = json['is_owner'];
    _isReply = json['is_reply'];
    _replies = json['replies'] != null ? (json['replies'] as List).map((i) => CommentData.fromJson(i)).toList() : [];
  }

  int? _userId;
  int? _reelId;
  String? _description;
  String? _updatedAt;
  String? _createdAt;
  int? _id;
  UserData? _user;
  int? _likesCount;
  bool? _isLiked;
  bool? _isOwner;
  bool? _isReply;
  List<CommentData>? _replies;
  int? get userId => _userId;

  int? get reelId => _reelId;

  String? get description => _description;

  String? get updatedAt => _updatedAt;

  String? get createdAt => _createdAt;

  int? get id => _id;

  UserData? get user => _user;

  int? get likesCount => _likesCount;

  bool? get isLiked => _isLiked;

  bool? get isOwner => _isOwner;

  bool? get isReply => _isReply;

  List<CommentData>? get replies => _replies;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['user_id'] = _userId;
    map['reel_id'] = _reelId;
    map['description'] = _description;
    map['updated_at'] = _updatedAt;
    map['created_at'] = _createdAt;
    map['id'] = _id;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    map['likes_count'] = _likesCount;
    map['is_liked'] = _isLiked;
    map['is_owner'] = _isOwner;
    map['is_reply'] = _isReply;
    if (_replies != null) {
      map['replies'] = _replies?.map((i) => i.toJson()).toList();
    }
    return map;
  }
}
