// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Category {
  String? id;
  String? title;
  String? image;
  String? slug;
  int? propertyType;

  //String? typeids;
  //List<Type>? type;
  Map? parameterTypes;
  //List<Map> fields = [];
  Category({this.id, this.title, this.image, this.slug, this.parameterTypes, this.propertyType});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    title = json['name'];
    image = json['image'] ?? "";
    slug = json['slug'];
    parameterTypes = json[parameterTypes] ?? {};
    propertyType = json['type'];
  }

  Category.fromProperty(Map<String, dynamic> json) {
    id = json['id'].toString();
    title = json['title'];
    slug = json['slug'];
    propertyType = json['propertyType'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'image': image,
      'slug': slug,
      'parameterTypes': parameterTypes,
      'propertyType': propertyType,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] != null ? map['id'] as String : null,
      title: map['title'] != null ? map['title'] as String : null,
      image: map['image'] != null ? map['image'] as String : null,
      slug: map['slug'] != null ? map['slug'] as String : null,
      parameterTypes: map['parameterTypes'],
      propertyType: map['propertyType'] != null ? map['propertyType'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
      return 'Category(id: $id, title: $title, image: $image, parameterTypes: $parameterTypes, propertyType: $propertyType)';
  }
}

class Type {
  String? id;
  String? type;

  Type({this.id, this.type});

  Type.fromJson(Map<String, dynamic> json) {
    id = json[id].toString();
    type = json[type];
  }
}
