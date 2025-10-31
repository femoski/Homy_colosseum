import 'package:homy/models/property/property_data.dart';
import 'package:homy/models/reels/comment_model.dart';
import 'package:homy/models/users/fetch_user.dart';

class ReelData {
  ReelData({
    int? id,
    int? userId,
    int? propertyId,
    String? description,
    String? latitude,
    String? longitude,
    String? content,
    String? thumbnail,
    String? hashtags,
    int? commentsCount,
    int? likesCount,
    int? viewsCount,
    String? createdAt,
    String? updatedAt,
    bool? isLike,
    int? isFollow,
    UserData? user,
    PropertyData? property,
    String? mediaUrl,
    bool? isSaved,
    List<CommentData>? comments,
    num? aspectRatio,

  }) {
    _id = id;
    _userId = userId;
    _propertyId = propertyId;
    _description = description;
    _latitude = latitude;
    _longitude = longitude;
    _content = content;
    _thumbnail = thumbnail;
    _hashtags = hashtags;
    _commentsCount = commentsCount;
    _likesCount = likesCount;
    _viewsCount = viewsCount;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _isLike = isLike;
    _isFollow = isFollow;
    _user = user;
    _property = property;
    _mediaUrl = mediaUrl;
    _comments = comments;
    _isSaved = isSaved;
    _aspectRatio = aspectRatio;
  }

  ReelData.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _propertyId = json['property_id'];
    _description = json['description'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
    _content = json['media_url'];
    _thumbnail = json['thumbnail_url'];
    _hashtags = json['hashtags'];
    _commentsCount = json['comments_count'];
    _likesCount = json['likes_count'];
    _viewsCount = json['views_count'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _isLike = json['is_like'];
    _isFollow = json['is_follow'];
    _user = json['user'] != null ? UserData.fromJson(json['user']) : null;
    _property = json['property'] != null ? PropertyData.fromJson(json['property']) : null;
    _mediaUrl = json['media_url'];
    _isSaved = json['is_saved'];
    _comments = json['reels_comments'] != null ? List<CommentData>.from(json['reels_comments'].map((i) => CommentData.fromJson(i))) : [];
    fetchReelSavedOrNot(json['id'].toString());
    _aspectRatio = json['aspect_ratio']?? 1;
  }

  fetchReelSavedOrNot(String id) {
    // List<String> savedIds = prefService.getSavedReelIds();

    // if (savedIds.contains(id)) {
    //   isSaved = 1;
    // } else {
    //   isSaved = 0;
    // }
  }

  int? _id;
  int? _userId;
  int? _propertyId;
  String? _description;
  String? _latitude;
  String? _longitude;
  String? _content;
  String? _thumbnail;
  String? _hashtags;
  int? _commentsCount;
  int? _likesCount;
  int? _viewsCount;
  String? _createdAt;
  String? _updatedAt;
  bool? _isLike;
  int? _isFollow;
  UserData? _user;
  PropertyData? _property;
  String? _mediaUrl;
  bool? _isSaved;
  List<CommentData>? _comments;
  num? _aspectRatio;

  int? get id => _id;

  int? get userId => _userId;

  int? get propertyId => _propertyId;

  String? get description => _description;

  String? get latitude => _latitude;

  String? get longitude => _longitude;

  String? get content => _content;

  String? get thumbnail => _thumbnail;

  String? get hashtags => _hashtags;

  int? get commentsCount => _commentsCount;

  bool? get isSaved => _isSaved;

  num? get aspectRatio => _aspectRatio;

  set aspectRatio(num? value) {
    _aspectRatio = value;
  }

  set isSaved(bool? value) {
    _isSaved = value;
  }

  set commentsCount(int? value) {
    _commentsCount = value;
  }

  List<CommentData>? get comments => _comments;

  int? get likesCount => _likesCount;

  set likesCount(int? value) {
    _likesCount = value;
  }

  String? get mediaUrl => _mediaUrl;

  int? get viewsCount => _viewsCount;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  bool? get isLike => _isLike;

  set isLike(bool? value) {
    _isLike = value;
  }

  int? get isFollow => _isFollow;

  set isFollow(int? value) {
    _isFollow = value;
  }

  UserData? get user => _user;

  PropertyData? get property => _property;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['property_id'] = _propertyId;
    map['description'] = _description;
    map['latitude'] = _latitude;
    map['longitude'] = _longitude;
    map['content'] = _content;
    map['thumbnail'] = _thumbnail;
    map['hashtags'] = _hashtags;
    map['comments_count'] = _commentsCount;
    map['likes_count'] = _likesCount;
    map['views_count'] = _viewsCount;
    map['media_url'] = _mediaUrl;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['is_like'] = _isLike;
    map['is_follow'] = _isFollow;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_property != null) {
      map['property'] = _property?.toJson();
    }
    return map;
  }
}

// class CommentData {
//   String? userName;
//   String? userImage;
//   String? text;
//   String? timeAgo;
//   // ... other comment-related fields
// }


// class CommentData1 {
//   CommentData1({
//     UserData? user,
//     String? text,
//     String? timeAgo,
//   }) {
//     _user = user;
//     _text = text;
//     _timeAgo = timeAgo;
//   }

//   UserData? _user;
//   String? _text;
//   String? _timeAgo;
// }
