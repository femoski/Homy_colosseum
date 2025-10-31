import 'package:homy/utils/constants.dart';
 
class Media{
  String? name;
  String? _url;
  String? _thumb;
  String? _icon;
  int? id;

  String get url => _url ?? "${Constants.baseUrl}images/image_default.png";

  String get thumb => _thumb ?? "${Constants.baseUrl}images/image_default.png";

  String get icon => _icon ?? "${Constants.baseUrl}images/image_default.png";

  set url(String? value) {
    _url = value ?? "${Constants.baseUrl}images/image_default.png";
  }

  set icon(String? value) {
    _icon = value ?? "${Constants.baseUrl}images/image_default.png";
  }

  set thumb(String? value) {
    _thumb = value ?? "${Constants.baseUrl}images/image_default.png";
  }

  Media({int? id, String? name, String? url, String? thumb, String? icon}) {
    this.id = id;
    this.name = name;
    this.url = url;
    this.thumb = thumb;
    this.icon = icon;
  }

  Media.fromJson(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'];
      name = jsonMap['name'];
      url = jsonMap['url'];
      thumb = jsonMap['thumb'];
      icon = jsonMap['icon'];
    } catch (e) {
      url = "${Constants.baseUrl}images/image_default.png";
      thumb = "${Constants.baseUrl}images/image_default.png";
      icon = "${Constants.baseUrl}images/image_default.png";
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["url"] = url;
    map["thumb"] = thumb;
    map["icon"] = icon;
    return map;
  }
}
