class ModuleModel {
  String? id;
  String? name;
  String? description;
  bool? enabled;
  Map<String, dynamic>? options;
  DateTime? createdAt;
  DateTime? updatedAt;

  ModuleModel({
    this.id,
    this.name,
    this.description,
    this.enabled,
    this.options,
    this.createdAt,
    this.updatedAt,
  });

  ModuleModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    description = json['description']?.toString();
    enabled = json['enabled'] == true;
    options = json['options'] as Map<String, dynamic>?;
    createdAt = json['created_at'] != null ? DateTime.parse(json['created_at']) : null;
    updatedAt = json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['enabled'] = enabled;
    if (options != null) {
      data['options'] = options;
    }
    data['created_at'] = createdAt?.toIso8601String();
    data['updated_at'] = updatedAt?.toIso8601String();
    return data;
  }

  // Helper methods
  bool get isEnabled => enabled == true;

  // Get option value with type safety
  T? getOption<T>(String key) {
    if (options == null || !options!.containsKey(key)) return null;
    
    final value = options![key];
    if (value is T) return value;
    
    // Try to convert string values to the requested type
    if (value is String) {
      switch (T) {
        case bool:
          return (value.toLowerCase() == 'true') as T;
        case int:
          return int.tryParse(value) as T?;
        case double:
          return double.tryParse(value) as T?;
        default:
          return null;
      }
    }
    return null;
  }

  // Set option with type safety
  void setOption<T>(String key, T value) {
    options ??= {};
    options![key] = value;
  }
} 