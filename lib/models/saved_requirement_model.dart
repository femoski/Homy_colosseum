
class SavedRequirement {
  final List<String> locations;
  final int? minPrice;
  final int? maxPrice;
  final List<String> propertyTypes;
  final List<String> selectedCategoryIds;
  final int? minBedrooms;
  final int? minBathrooms;
  final double? minArea;
  final double? maxArea;
  final int? locationType; // 0: by city, 1: by location with radius
  final String? selectedLocationName;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final String? selectedCategoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedRequirement({
    this.locations = const [],
    this.minPrice,
    this.maxPrice,
    this.propertyTypes = const [],
    this.selectedCategoryIds = const [],
    this.minBedrooms,
    this.minBathrooms,
    this.minArea,
    this.maxArea,
    this.locationType,
    this.selectedLocationName,
    this.latitude,
    this.longitude,
    this.radius,
    this.selectedCategoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Create a copy with updated fields
  SavedRequirement copyWith({
    List<String>? locations,
    int? minPrice,
    int? maxPrice,
    List<String>? propertyTypes,
    List<String>? selectedCategoryIds,
    int? minBedrooms,
    int? minBathrooms,
    double? minArea,
    double? maxArea,
    int? locationType,
    String? selectedLocationName,
    double? latitude,
    double? longitude,
    double? radius,
    String? selectedCategoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedRequirement(
      locations: locations ?? this.locations,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      locationType: locationType ?? this.locationType,
      selectedLocationName: selectedLocationName ?? this.selectedLocationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'locations': locations,
      'min_price': minPrice,
      'max_price': maxPrice,
      'property_types': propertyTypes,
      'selected_category_id': selectedCategoryIds,
      'min_bedrooms': minBedrooms,
      'min_bathrooms': minBathrooms,
      'min_area': minArea,
      'max_area': maxArea,
      'location_type': locationType,
      'selected_location_name': selectedLocationName,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory SavedRequirement.fromJson(Map<String, dynamic> json) {
    return SavedRequirement(
      locations: List<String>.from(json['locations'] ?? []),
      minPrice: json['min_price'],
      maxPrice: json['max_price'],
      propertyTypes: List<String>.from(json['property_types'] ?? []),
      selectedCategoryIds: List<String>.from(json['selected_category_id'] ?? []),
      minBedrooms: json['min_bedrooms'],
      minBathrooms: json['min_bathrooms'],
      minArea: json['min_area'] != null ? double.tryParse(json['min_area'].toString()) : null,
      maxArea: json['max_area'] != null ? double.tryParse(json['max_area'].toString()) : null,
      locationType: json['location_type'],
      selectedLocationName: json['selected_location_name'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      radius: json['radius'] != null ? double.tryParse(json['radius'].toString()) : null,
      selectedCategoryId: null, // This field is deprecated, use selectedCategoryIds instead
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  // Create empty requirement
  factory SavedRequirement.empty() {
    final now = DateTime.now();
    return SavedRequirement(
      locations: [],
      propertyTypes: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  // Check if requirement is empty
  bool get isEmpty {
    return locations.isEmpty && 
           minPrice == null && 
           maxPrice == null && 
           propertyTypes.isEmpty && 
           minBedrooms == null && 
           minBathrooms == null &&
           minArea == null &&
           maxArea == null &&
           locationType == null &&
           selectedLocationName == null;
  }

  // Check if requirement has any criteria set
  bool get hasCriteria {
    return locations.isNotEmpty || 
           minPrice != null || 
           maxPrice != null || 
           propertyTypes.isNotEmpty || 
           minBedrooms != null || 
           minBathrooms != null ||
           minArea != null ||
           maxArea != null ||
           locationType != null ||
           selectedLocationName != null;
  }

  // Get formatted price range string
  String get priceRangeString {
    if (minPrice == null && maxPrice == null) return 'Any';
    if (minPrice == null) return 'Up to ₦${_formatPrice(maxPrice!)}';
    if (maxPrice == null) return 'From ₦${_formatPrice(minPrice!)}';
    return '₦${_formatPrice(minPrice!)} - ₦${_formatPrice(maxPrice!)}';
  }

  // Get formatted bedrooms string
  String get bedroomsString {
    if (minBedrooms == null) return 'Any';
    return '$minBedrooms+';
  }

  // Get formatted bathrooms string
  String get bathroomsString {
    if (minBathrooms == null) return 'Any';
    return '$minBathrooms+';
  }

  // Get formatted locations string
  String get locationsString {
    if (locations.isEmpty) return 'Any location';
    if (locations.length == 1) return locations.first;
    if (locations.length == 2) return '${locations.first} & ${locations.last}';
    return '${locations.first} & ${locations.length - 1} more';
  }

  // Get formatted property types string
  String get propertyTypesString {
    if (propertyTypes.isEmpty) return 'Any type';
    if (propertyTypes.length == 1) return propertyTypes.first;
    if (propertyTypes.length == 2) return '${propertyTypes.first} & ${propertyTypes.last}';
    return '${propertyTypes.first} & ${propertyTypes.length - 1} more';
  }

  // Helper method to format price
  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    }
    return price.toString();
  }

  @override
  String toString() {
    return 'SavedRequirement(locations: $locations, minPrice: $minPrice, maxPrice: $maxPrice, propertyTypes: $propertyTypes, minBedrooms: $minBedrooms, minBathrooms: $minBathrooms)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedRequirement &&
        other.locations.toString() == locations.toString() &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.propertyTypes.toString() == propertyTypes.toString() &&
        other.minBedrooms == minBedrooms &&
        other.minBathrooms == minBathrooms;
  }

  @override
  int get hashCode {
    return locations.hashCode ^
        minPrice.hashCode ^
        maxPrice.hashCode ^
        propertyTypes.hashCode ^
        minBedrooms.hashCode ^
        minBathrooms.hashCode;
  }
}
