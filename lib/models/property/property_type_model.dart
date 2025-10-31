class PropertyType {
  PropertyType({
    int? id,
    String? title,
    int? propertyCategory,
    String? icon,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _title = title;
    _propertyCategory = propertyCategory;
    _icon = icon;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  PropertyType.fromJson(dynamic json) {
    _id = json['id'];
    _title = json['title'];
    _propertyCategory = json['property_category'];
    _icon = json['icon'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  int? _id;
  String? _title;
  int? _propertyCategory;
    String? _icon;
  String? _createdAt;
  String? _updatedAt;

  int? get id => _id;

  String? get title => _title;

  int? get propertyCategory => _propertyCategory;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  String? get icon => _icon;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['title'] = _title;
    map['property_category'] = _propertyCategory;
    map['icon'] = _icon;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
