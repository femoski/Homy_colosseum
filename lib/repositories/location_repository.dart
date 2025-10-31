import 'dart:convert';
import 'package:homy/models/location/prediction_model.dart';
import 'package:homy/providers/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:homy/models/place_model.dart';
import 'package:homy/utils/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

class LocationRepository {

  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  // LocationRepository({ this.apiClient});

  Future<String> getAddressFromGeocode(LatLng latLng) async {
    Response response = await apiClient.getData('${Constants.geocodeUri}?lat=${latLng.latitude}&lng=${latLng.longitude}', handleError: false);
    String address = 'Unknown Location Found';
    if(response.statusCode == 200 && response.body['data']['status'] == 'OK') {
      address = response.body['data']['results'][0]['formatted_address'].toString();
    }
    return address;
  }

  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  
  /// Search for cities/places based on input text
  Future<List<PlaceModel>> searchCities(String searchText) async {
    try {
            final response  = await apiClient.getData('place-api-autocomplete?search_text=$searchText&types=locality', handleError: false);

      // final response = await http.get(
      //   Uri.parse(
      //     '$_baseUrl/autocomplete/json?input=$searchText&key=${Constants.googleApiKey}&types=locality'
      //   ),
      // );

      if (response.statusCode == 200) {
        final data = response.body['data'];
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;


          return predictions.map((place){
            final List<dynamic> terms = place['terms'];
            final String state = terms.length > 1 ? terms[1]['value'] : '';
            final String country = terms.length > 2 ? terms[2]['value'] : '';
     final String city = terms.firstWhere(
              (term) => term['value'] != null,
              orElse: () => {},
            )['value'] ??
            '';
            return PlaceModel(
              placeId: place['place_id'],
              description: place['description'],
              formattedAddress: '$city',
              city: city,
              state: state,
              country: state,
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PredictionModel>> searchLocation(String text) async {
    try {
      final response = await apiClient.getData('place-api-autocomplete?search_text=$text&types=locality', handleError: false);

      // final response = await http.get(Uri.parse('$_baseUrl/autocomplete/json?input=$text&key=${Constants.googleApiKey}'));
      if (response.statusCode == 200) {
        final data = response.body['data'];
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions
              .map((prediction) => PredictionModel.fromJson(prediction))
              .toList()
              .cast<PredictionModel>();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

/// Get place details from placeId
  Future<Map<String, dynamic>> getPlaceDetailsFromPlaceId(String? placeId) async {
    try {
      final response = await apiClient.getData('place-api-details?place_id=$placeId', handleError: false);
  
      // final response = await http.get(
      //   Uri.parse(
      //     '$_baseUrl/details/json?place_id=$placeId&key=${Constants.googleApiKey}'
      //   ),
      // );

      // Get.log('$_baseUrl/details/json?place_id=$placeId&key=${Constants.googleApiKey}');
      if (response.statusCode == 200) {
        final data = response.body['data'];
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final addressComponents = data['result']['address_components'] as List;
          
          String? state;
          for (var component in addressComponents) {
            final types = component['types'] as List;
            if (types.contains('administrative_area_level_1')) {
              state = component['long_name'];
              break;
            }
          }

          Get.log('state: $state');
          return {
            'lat': location['lat'],
            'lng': location['lng'],
            'state': state ?? '',
          };
        }
      }
      throw Exception('Failed to get place details');
    } catch (e) {
      rethrow;
    }
  }

  Future<PlaceModel> getLocation(LatLng latLng) async {
    try{
    final response = await apiClient.getData('location/get-location?lat=${latLng.latitude}&lng=${latLng.longitude}', handleError: false);
    return PlaceModel.fromJson(response.body['data']);
    }catch(e){
      rethrow;
    }
  }
}
