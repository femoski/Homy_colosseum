class PlaceModel {
  final String placeId;
  final String description;
  final String? formattedAddress;
  final String? city;
  final String? state;
  final String? country;
  final String? latitude;
  final String? longitude;

  PlaceModel({
    required this.placeId,
    required this.description,
    this.formattedAddress,
    this.city,
    this.state,
    this.country,
    this.latitude,
    this.longitude,
  });

  PlaceModel copyWith({
    String? placeId,
    String? description,
    String? formattedAddress,
    String? city,
    String? state,
    String? country,
    String? latitude,
    String? longitude,
  }) {
    return PlaceModel(
      placeId: placeId ?? this.placeId,
      description: description ?? this.description,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // Add fromJson if needed
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
    );
  }

  // Add toJson if needed
  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'description': description,
      'formatted_address': formattedAddress,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'country': country,
    };
  }
} 