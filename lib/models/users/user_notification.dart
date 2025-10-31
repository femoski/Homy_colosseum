import 'package:homy/models/users/fetch_user.dart';

class UserNotificationData {
  UserNotificationData({
    int? id,
    int? myUserId,
    int? userId,
    int? itemId,
    int? type,
    String? message,
    String? createdAt,
    String? updatedAt,
    UserData? user,
    bool? isRead,
  }) {
    _id = id;
    _myUserId = myUserId;
    _userId = userId;
    _itemId = itemId;
    _type = type;
    _message = message;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _user = user;
    _isRead = isRead;
  }

  UserNotificationData.fromJson(dynamic json) {
    _id = json['id'];
    _myUserId = json['my_user_id'];
    _userId = json['user_id'];
    _itemId = json['item_id'];
    _type = json['type'];
    _message = json['message'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _user = json['user'] != null ? UserData.fromJson(json['user']) : null;
    _isRead = json['is_read'];
  }

  int? _id;
  int? _myUserId;
  int? _userId;
  int? _itemId;
  int? _type;
  String? _message;
  String? _createdAt;
  String? _updatedAt;
  UserData? _user;
  bool? _isRead;

  int? get id => _id;

  int? get myUserId => _myUserId;

  int? get userId => _userId;

  int? get itemId => _itemId;

  int? get type => _type;

  String? get message => _message;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  UserData? get user => _user;

  bool? get isRead => _isRead;

  UserNotificationData copyWith({
    int? id,
    int? myUserId,
    int? userId,
    int? itemId,
    int? type,
    String? message,
    String? createdAt,
    String? updatedAt,
    UserData? user,
    bool? isRead,
  }) {
    return UserNotificationData(
      id: id ?? this._id,
      myUserId: myUserId ?? this._myUserId,
      userId: userId ?? this._userId,
      itemId: itemId ?? this._itemId,
      type: type ?? this._type,
      message: message ?? this._message,
      createdAt: createdAt ?? this._createdAt,
      updatedAt: updatedAt ?? this._updatedAt,
      user: user ?? this._user,
      isRead: isRead ?? this._isRead,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['my_user_id'] = _myUserId;
    map['user_id'] = _userId;
    map['item_id'] = _itemId;
    map['type'] = _type;
    map['message'] = _message;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    map['is_read'] = _isRead;
    return map;
  }
}
