import 'package:get/get.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';

class LikesRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  // Toggle like on a reel
  Future<Map<String, dynamic>> toggleReelLike(int reelId) async {
    try {
      final response = await apiClient.getData(
        'reels/$reelId/like',
      );

      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw 'Failed to toggle like';
      }
    } catch (e) {
      // Get.snackbar(
      //   'Error',
      //   'Failed to toggle like: $e',
      //   snackPosition: SnackPosition.TOP,
      // );
      rethrow;
    }
  }

  // Toggle like on a property
  Future<Map<String, dynamic>> togglePropertyLike(int propertyId) async {
    try {
      final response = await apiClient.getData(
        'properties/$propertyId/toggle-like',
      );

      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw 'Failed to toggle property like';
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get liked reels for a user
  Future<List<int>> getLikedReels() async {
    try {
      final response = await apiClient.getData('reels/liked');

      if (response.statusCode == 200) {
        final List<dynamic> likedReels = response.body['data'];
        return likedReels.map((reel) => reel['reel_id'] as int).toList();
      } else {
        throw 'Failed to fetch liked reels';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch liked reels: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Get liked properties for a user
  Future<List<int>> getLikedProperties() async {
    try {
      final response = await apiClient.getData('properties/liked');

      if (response.statusCode == 200) {
        final List<dynamic> likedProperties = response.body['data'];
        return likedProperties.map((property) => property['property_id'] as int).toList();
      } else {
        throw 'Failed to fetch liked properties';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch liked properties: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }
} 