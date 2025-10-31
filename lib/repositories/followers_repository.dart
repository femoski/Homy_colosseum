import 'package:get/get.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';

class FollowersRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  // Follow/Unfollow a user
  Future<dynamic> toggleFollow(int userId, bool isFollowing) async {
    try {
      // final endpoint = isFollowing ? 'users/$userId/unfollow' : 'users/$userId/follow';
      final endpoint = 'follow/$userId';

      final response = await apiClient.getData(endpoint,);

      if (response.statusCode != 200) {
        throw 'Failed to ${isFollowing ? 'unfollow' : 'follow'} user';
      }
      return response.body['data'];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to ${isFollowing ? 'unfollow' : 'follow'} user: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Get user followers
  Future<List<UserData>> getFollowers(int userId, {int start = 0, int limit = 20}) async {
    try {
      final response = await apiClient.getData(
        'users/$userId/followers',
        query: {
          'start': start.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> followersData = response.body['data'];
        return followersData.map((data) => UserData.fromJson(data)).toList();
      } else {
        throw 'Failed to fetch followers';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch followers: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Get user following
  Future<List<UserData>> getFollowing(int userId, {int start = 0, int limit = 20}) async {
    try {
      final response = await apiClient.getData(
        'users/$userId/following',
        query: {
          'start': start.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> followingData = response.body['data'];
        return followingData.map((data) => UserData.fromJson(data)).toList();
      } else {
        throw 'Failed to fetch following';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch following: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Get follower/following count
  Future<Map<String, int>> getFollowCounts(int userId) async {
    try {
      final response = await apiClient.getData('users/$userId/follow-counts');

      if (response.statusCode == 200) {
        final data = response.body['data'];
        return {
          'followers': data['followers_count'] ?? 0,
          'following': data['following_count'] ?? 0,
        };
      } else {
        throw 'Failed to fetch follow counts';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch follow counts: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Check if user is following another user
  Future<bool> isFollowing(int userId, int targetUserId) async {
    try {
      final response = await apiClient.getData(
        'users/$userId/is-following/$targetUserId',
      );

      if (response.statusCode == 200) {
        return response.body['data']['is_following'] ?? false;
      } else {
        throw 'Failed to check following status';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to check following status: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }
} 