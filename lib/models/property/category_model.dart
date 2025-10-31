
import 'dart:convert';

class Categorys {
  Categorys({
    this.id,
    this.category,
    this.image,
  });

  final int? id;
  final String? category;
  final String? image;

  Categorys copyWith({
    int? id,
    String? category,
    String? image,
  }) =>
      Categorys(
        id: id ?? this.id,
        category: category ?? this.category,
        image: image ?? this.image,
      );

  factory Categorys.fromJson(String str) => Categorys.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Categorys.fromMap(Map<String, dynamic> json) => Categorys(
        id: json["id"],
        category: json["category"],
        image: json["image"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "category": category,
        "image": image,
      };
}
