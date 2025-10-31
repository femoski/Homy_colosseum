class NotificationData {
  NotificationData({
    int? id,
    String? title,
    String? description,
    String? createdAt,
    String? updatedAt,
    bool? isRead,
  }) {
    _id = id;
    _title = title;
    _description = description;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _isRead = isRead;
  }

  NotificationData.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _description = json['description'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updated_at'];
    _isRead = json['is_read'] ?? false;
  }

  int? _id;
  String? _title;
  String? _description;
  String? _createdAt;
  String? _updatedAt;
  bool? _isRead;
  int? get id => _id;

  String? get title => _title;

  String? get description => _description;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  bool? get isRead => _isRead;

  set isRead(bool? value) {
    _isRead = value;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['description'] = _description;
    map['createdAt'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['is_read'] = _isRead ?? false;
    return map;
  }

  NotificationData copyWith({
    int? id,
    String? title,
    String? description,
    String? createdAt,
    String? updatedAt,
    bool? isRead,
  }) {
    return NotificationData(
      id: id ?? this._id,
      title: title ?? this._title,
      description: description ?? this._description,
      createdAt: createdAt ?? this._createdAt,
      updatedAt: updatedAt ?? this._updatedAt,
      isRead: isRead ?? false,
    );
  }
}
