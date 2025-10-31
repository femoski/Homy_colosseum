import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';
import 'package:image_picker/image_picker.dart';

class UserRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  Future<UserData> signIn(
      {required String? email, required String? password, String? deviceType}) async {
    try {
      final response = await apiClient.postData(
          'login', {'username': email, 'password': password, 'device_type': deviceType},
          handleError: false);
      if (response.statusCode == 200) {
        if (response.body['data']['activation_type'] == 'user_email_activate' || response.body['data']['activation_type'] == 'user_phone_activate') {
          Get.offNamed('/verify-registration', arguments: {
            'email': response.body['data']['user']['email'],
            'phone': response.body['data']['user']['phone'],
            'user_id': response.body['data']['user']['user_id'],
            'user_data': response.body['data']['user'],
            'activation_type': response.body['data']['activation_type'],
          });
          throw response.body['data']['message'].toString();
        }
        return UserData.fromJson(response.body['data']['user']);
      } else {
        throw response.body['message'].toString();
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Fetch user profile
  Future<UserData> getUserProfile(int userId) async {
    try {
      final response = await apiClient.getData(
        'agents/$userId',
        query: {'user_id': userId.toString()},
      );

      if (response.statusCode == 200) {
        return UserData.fromJson(response.body['data']);
      } else {
        throw 'Failed to fetch user profile: ${response.statusText}';
      }
    } catch (e) {
      throw 'Failed to fetch user profile: $e';
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> userData) async {
    // try {
    //   final response = await apiClient.putData(
    //     UrlRes.updateUserProfile,
    //     userData,
    //   );

    //   if (response.statusCode != 200) {
    //     throw Exception('Failed to update profile: ${response.statusText}');
    //   }
    // } catch (e) {
    //   throw Exception('Failed to update profile: $e');
    // }
  }

  // Follow/Unfollow user
  Future<void> toggleFollowUser(int userId, bool isFollowing) async {
    // try {
    //   final endpoint = isFollowing ? UrlRes.followUser : UrlRes.unfollowUser;
    //   final response = await apiClient.postData(
    //     endpoint,
    //     {'user_id': userId},
    //   );

    //   if (response.statusCode != 200) {
    //     throw Exception('Failed to ${isFollowing ? 'follow' : 'unfollow'} user: ${response.statusText}');
    //   }
    // } catch (e) {
    //   Get.snackbar(
    //     'Error',
    //     'Failed to ${isFollowing ? 'follow' : 'unfollow'} user: $e',
    //     snackPosition: SnackPosition.TOP,
    //   );
    // }
  }

  // Get user followers
  Future<List<UserData>> getUserFollowers(int userId,
      {int start = 0, int limit = 20}) async {
    try {
      final response = await apiClient.getData(
        '/users/$userId/followers',
        query: {'start': start.toString(), 'limit': limit.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> followersData = response.body['data'];
        return followersData.map((data) => UserData.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch followers: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Failed to fetch followers: $e');
    }
  }

  // Get user following
  Future<List<UserData>> getUserFollowing(int userId,
      {int start = 0, int limit = 20}) async {
    try {
      final response = await apiClient.getData(
        '/users/$userId/following',
        query: {'start': start.toString(), 'limit': limit.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> followersData = response.body['data'];
        return followersData.map((data) => UserData.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch followers: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Failed to fetch followers: $e');
    }
  }

  // Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications() async {
    // try {
    //   final response = await apiClient.getData(UrlRes.fetchUserNotifications);

    //   if (response.statusCode == 200) {
    //     final List<dynamic> notificationsData = response.body['data'];
    //     return notificationsData.cast<Map<String, dynamic>>();
    //   } else {
    //     throw Exception('Failed to fetch notifications: ${response.statusText}');
    //   }
    // } catch (e) {
    //   throw Exception('Failed to fetch notifications: $e');
    // }
    return [];
  }

  Future<UserData> fetchProfile() async {
    try {
      final response = await apiClient.getData('users/profile');
      if (response.statusCode == 200) {
        return UserData.fromJson(response.body['data']);
      } else {
        throw Exception(response.body['message'].toString());
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserData> updateProfile(
      Map<String, dynamic> userData, Map<String, List<XFile>>? filesMap) async {
    try {
      final response = await apiClient.multiPartRequestWeb(
        url: 'users/profile',
        fields: userData,
        filesMap: filesMap ?? {},
      );
      if (response.statusCode == 200) {
        return UserData.fromJson(response.body['data']);
      } else {
        throw Exception(response.body['message'].toString());
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateFCMToken(String token) async {
    try {
      final response = await apiClient.postData('user/update-fcm-token', {
        'device_token': token,
      });
      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw Exception(response.body['message'].toString());
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    final response = await apiClient.postData('logout', {});
    if (response.statusCode == 200) {
      return;
    }
  }

  // Get user reels
  Future<List<ReelData>> getUserReels(int userId) async {
    try {
      final response = await apiClient.getData(
        'reels/user/$userId',
        query: {'reels_by_user': userId.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> reelsData = response.body['data'];
        return reelsData.map((data) => ReelData.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch user reels: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user reels: $e');
    }
  }

  Future<Map<String, dynamic>> registerAsAgent(
      Map<String, dynamic> data, Map<String, List<XFile>>? filesMap) async {
    try {
      final response = await apiClient.multiPartRequestWeb(
        url: 'register-agent',
        fields: data,
        filesMap: filesMap ?? {},
      );
      return response.body;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkAgentRegistration() async {
    final response = await apiClient.getData('agent/check-registration-status');
    return response.body['data'];
  }

  Future<Map<String, dynamic>> verifyCode(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.postData('/verification/verify', data,
          handleError: false);
      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        return {'status': false, 'message': response.body['message'].toString()};
      }
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyPhone(Map<String, dynamic> data) async {
    // Implement API call
    return {'status': true}; // Placeholder
  }

  Future<Map<String, dynamic>> resendEmailCode(
      Map<String, dynamic> data) async {
    try {
      final response = await apiClient.postData('verification/resend-email', data);
      
      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw response.body['message'].toString();
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> resendPhoneCode(
      Map<String, dynamic> data) async {
    try {
      final response = await apiClient.postData('verification/resend-phone', data);
      
      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw response.body['message'].toString();
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> updatePhone(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.postData('users/update-phone', data);
      
      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw response.body['message'].toString();
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.postData('register', data);

      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        print('response111: ${response.statusText}');
        throw response.statusText.toString();
        throw Exception(response.body['message'].toString());
      }
    } catch (e) {
      print('response111: ${e.toString()}');

      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> changePassword(Map<String, dynamic> data) async {
    final response = await apiClient.postData('user/change-password', data);
    try {
      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw response.statusText.toString();
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteAccount({required String password, String? reason}) async {
    final response = await apiClient.postData(
      'users/delete-account',
      {
        'password': password,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );

    if (response.statusCode != 200) {
      throw response.body['message'] ?? 'Failed to delete account';
    }
  }

  // Block/Unblock user
  Future<Map<String, dynamic>> toggleBlockUser(String userId) async {
    try {
      final response = await apiClient.postData(
        'users/$userId/toggle-block',
        {},
      );

      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw response.body['message'] ?? 'Failed to toggle block status';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update block status: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Report user
  Future<void> reportUser({
    required int userId,
    required String reason,
    String? additionalDetails,
  }) async {
    try {
      final response = await apiClient.postData(
        'users/${userId.toString()}/report',
        {
          'reported_user_id': userId,
          'reason': reason,
          if (additionalDetails != null && additionalDetails.isNotEmpty)
            'additional_details': additionalDetails,
        },
      );

      if (response.statusCode != 200) {
        throw response.body['message'] ?? 'Failed to report user';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to report user: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Check if user is blocked
  Future<bool> isUserBlocked(int userId) async {
    try {
      final response = await apiClient.getData('users/block-status/$userId');

      if (response.statusCode == 200) {
        return response.body['data']['is_blocked'] ?? false;
      } else {
        throw response.body['message'] ?? 'Failed to check block status';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to check block status: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> forgotPassword(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.postData('password/forgot', data);
      
      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw response.body['data']['message'].toString();
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.postData('/password/verify-code', data);
      
      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw response.body['message'].toString();
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.postData('/password/reset', data);
      
      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw response.body['message'].toString();
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Map<String, dynamic>> checkEmailExists(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.postData('users/change-verification-email', data, handleError: false);
      Get.log('responsesdasda: ${response.body}');
      if (response.statusCode == 200) {
        return {'message': response.body['data']['message'] ,'exists': true};
      } else {
        return {'message': response.body['data']['message'] ,'exists': false};
      }
    } catch (e) {
      return {'exists': false};
    }
  }

  Future<Map<String, dynamic>> checkPhoneExists(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.postData('users/change-verification-phone', data, handleError: false);
      if (response.statusCode == 200) {
        return {'message': response.body['data']['message'] ,'exists': true};
      } else {
        return {'message': response.body['data']['message'] ,'exists': false};
      }
    } catch (e) {
      return {'exists': false};
    }
  }
}
