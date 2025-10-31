import 'package:get/get.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';

class SavedRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  // Toggle save status for a reel
  Future<Map<String, dynamic>> toggleReelSave(int reelId) async {
    try {
      final response = await apiClient.getData(
        'reels/$reelId/save',
      );

      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw 'Failed to toggle save';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to toggle save: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Toggle save status for a property
  Future<Map<String, dynamic>> togglePropertySave(int propertyId) async {
    try {
      final response = await apiClient.getData(
        'properties/$propertyId/save',
      );

      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw 'Failed to toggle property save';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to toggle property save: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Get saved reels
  Future<List<ReelData>> getSavedReels({int start = 0, int limit = 20}) async {
    try {
      final response = await apiClient.getData(
        'reels/saved',
        query: {
          'start': start.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> reelsData = response.body['data'];
        return reelsData.map((data) => ReelData.fromJson(data)).toList();
      } else {
        throw 'Failed to fetch saved reels';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch saved reels: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Get saved properties
  Future<List<PropertyData>> getSavedProperties({int start = 0, int limit = 20}) async {
    try {
      final response = await apiClient.getData(
        'properties/saved',
        query: {
          'start': start.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> propertiesData = response.body['data'];
        return propertiesData.map((data) => PropertyData.fromJson(data)).toList();
      } else {
        throw 'Failed to fetch saved properties';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch saved properties: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }
} 