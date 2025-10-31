import 'package:homy/models/place_model.dart';
import 'package:homy/repositories/location_repository.dart';

class GooglePlaceService {
  late LocationRepository _locationRepository;

  GooglePlaceService(){

    _locationRepository = LocationRepository();
  }

  /// Search for places based on input text
  Future<List<PlaceModel>> searchPlaces(String query) async {
    try {
      final results = await _locationRepository.searchCities(query);
      return results.map((place) => PlaceModel(
        placeId: place.placeId,
        description: place.description,
      )).toList();
    } catch (e) {
      // Handle error appropriately
      rethrow;
    }
  }

  /// Get detailed place information from placeId
  Future<PlaceCoordinates> getPlaceDetails(String placeId) async {
    try {
      final details = await _locationRepository.getPlaceDetailsFromPlaceId(placeId);
      return PlaceCoordinates(
        latitude: details['lat'] as double,
        longitude: details['lng'] as double,
      );
    } catch (e) {
      // Handle error appropriately
      rethrow;
    }
  }
}

class PlaceCoordinates {
  final double latitude;
  final double longitude;

  PlaceCoordinates({
    required this.latitude, 
    required this.longitude
  });
} 