class PropertyMessage {
  int? _propertyId;
  List<String>? _image;
  String? _title;
  String? _propertyType;
  String? _address;
  String? _message;

  PropertyMessage(
      {int? propertyId,
      List<String>? image,
      String? title,
      String? propertyType,
      String? address,
      String? message}) {
    if (propertyId != null) {
      _propertyId = propertyId;
    }
    if (image != null) {
      _image = image;
    }
    if (title != null) {
      _title = title;
    }
    if (propertyType != null) {
      _propertyType = propertyType;
    }
    if (address != null) {
      _address = address;
    }
    if (message != null) {
      _message = message;
    }
  }

  int? get propertyId => _propertyId;

  List<String>? get image => _image;

  String? get title => _title;

  String? get propertyType => _propertyType;

  String? get address => _address;

  String? get message => _message;

  PropertyMessage.fromJson(Map<String, dynamic> json) {
    _propertyId = json['propertyId'];
    _image = json['image'] == null
        ? []
        : List<String>.from(json["image"].map((x) => x));
    _title = json['title'];
    _propertyType = json['propertyType'];
    _address = json['address'];
    _message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['propertyId'] = _propertyId;
    data['image'] = _image;
    data['title'] = _title;
    data['propertyType'] = _propertyType;
    data['address'] = _address;
    data['message'] = _message;
    return data;
  }
}
