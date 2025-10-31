class Media {
  Media({
    int? id,
    int? propertyId,
    int? mediaTypeId,
    String? name,
    String? content,
    String? thumbnail,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _propertyId = propertyId;
    _mediaTypeId = mediaTypeId;
    _content = content;
    _thumbnail = thumbnail;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Media.fromJson(dynamic json) {
    _id = json['id'];
    _propertyId = json['property_id'];
    _mediaTypeId = json['media_type_id'];
    _content = json['content'];
    _thumbnail = json['thumbnail'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  int? _id;
  int? _propertyId;
  int? _mediaTypeId;
  String? _content;
  String? _thumbnail;
  String? _createdAt;
  String? _updatedAt;

  int? get id => _id;

  int? get propertyId => _propertyId;

  int? get mediaTypeId => _mediaTypeId;

  String? get content => _content;

  String? get thumbnail => _thumbnail;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['property_id'] = _propertyId;
    map['media_type_id'] = _mediaTypeId;
    map['content'] = _content;
    map['thumbnail'] = _thumbnail;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}