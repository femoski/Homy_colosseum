import 'package:get/get.dart';
import 'package:homy/models/settings/module_model.dart';

class SettingsModel {
  String? id;
  String? key;
  String? value;
  bool? enabled;
  ModuleModel? module;
  DateTime? createdAt;
  DateTime? updatedAt;

  SettingsModel({
    this.id,
    this.key,
    this.value,
    this.enabled,
    this.module,
    this.createdAt,
    this.updatedAt,
  });

  SettingsModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    key = json['key']?.toString();
    value = json['value']?.toString();
    enabled = json['enabled'] == true;
    module = json['module'] != null ? ModuleModel.fromJson(json['module']) : null;
    createdAt = json['created_at'] != null ? DateTime.parse(json['created_at']) : null;
    updatedAt = json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['key'] = key;
    data['value'] = value;
    data['enabled'] = enabled;
    if (module != null) {
      data['module'] = module!.toJson();
    }
    data['created_at'] = createdAt?.toIso8601String();
    data['updated_at'] = updatedAt?.toIso8601String();
    return data;
  }

  // Helper methods for common settings
  bool get isEnabled => enabled == true;
  
  // Parse value based on type
  T? getValue<T>() {
    if (value == null) return null;
    
    switch (T) {
      case bool:
        return (value?.toLowerCase() == 'true') as T;
      case int:
        return int.tryParse(value!)as T?;
      case double:
        return double.tryParse(value!) as T?;
      case String:
        return value as T;
      default:
        return null;
    }
  }
} 