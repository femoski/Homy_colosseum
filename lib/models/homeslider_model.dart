import 'package:homy/models/media_model.dart';

class HomeSlider {
  int? _id;
  int? _order;
  String? _image;
  bool? _promoted;
  String? _title;
  String? _subtitle;
  String? _propertysId;
  Media? _media;

  // Getters
  int? get id => _id;
  int? get order => _order;
  String? get image => _image;
  bool? get promoted => _promoted;
  String? get title => _title;
  String? get subtitle => _subtitle;
  String? get propertysId => _propertysId;
  Media? get media => _media;

  // // Computed Getters
  // String get url => _image ?? _media?.url ?? '';
  // String get imageUrl => _media?.thumb ?? _image ?? '';
  // String get displayTitle => _title ?? '';
  // String get displaySubtitle => _subtitle ?? '';

  // // Setters
  // set id(int? value) => _id = value;
  // set order(int? value) => _order = value;
  // set image(String? value) => _image = value;
  // set promoted(bool? value) => _promoted = value;
  // set title(String? value) => _title = value;
  // set subtitle(String? value) => _subtitle = value;
  // set propertysId(String? value) => _propertysId = value;
  // set media(Media? value) => _media = value;

  HomeSlider({
    int? id,
    int? order,
    String? image,
    bool? promoted,
    String? title,
    String? subtitle,
    String? propertysId,
  }) : 
    _id = id,
    _order = order,
    _image = image,
    _promoted = promoted,
    _title = title,
    _subtitle = subtitle,
    _propertysId = propertysId;

  HomeSlider.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _order = json['order'];
    _image = json['image'];
    _promoted = json['promoted'];
    _title = json['title'];
    _subtitle = json['subtitle'];
    _propertysId = json['propertysId'];
    _media = mediaFromJson(json, 'media');
  }
}

Media mediaFromJson(Map<String, dynamic>? json, String attribute) {
  try {
    Media media = Media();
    if (json != null &&
        json['media'] != null &&
        (json['media'] as List).length > 0) {
      media = Media.fromJson(json['media'][0]);
    }
    return media;
  } catch (e) {
    throw Exception(
        'Error while parsing ' + attribute + '[' + e.toString() + ']');
  }
}