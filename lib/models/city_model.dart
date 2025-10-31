class CityModel {
  final String _id;
  final String _name;
  final String _image;
  final int _propertyCount;

  // Getters
  String get id => _id;
  String get name => _name;
  String get image => _image;
  int get propertyCount => _propertyCount;

  CityModel({
    required String id,
    required String name,
    required String image,
    required int propertyCount,
  })  : _id = id,
        _name = name,
        _image = image,
        _propertyCount = propertyCount;

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      propertyCount: json['property_count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': _id,
        'name': _name,
        'image': _image,
        'property_count': _propertyCount,
      };

  @override
  String toString() {
    return 'CityModel(id: $_id, name: $_name, image: $_image, propertyCount: $_propertyCount)';
  }
} 