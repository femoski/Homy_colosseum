import 'dart:io';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';
import 'package:homy/utils/url_res.dart';

class ReelsRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  // Upload reel video
  Future<String> uploadReelVideo(XFile videoFile) async {
    // try {
    //   final formData = {
    //     'video': await MultipartFile.fromFile(
    //       videoFile.path,
    //       filename: 'reel_${DateTime.now().millisecondsSinceEpoch}.mp4',
    //     ),
    //   };

    //   final response = await apiClient.postMultipart('upload-reel-video', formData);
      
    //   if (response.statusCode == 200) {
    //     return response.body['data']['videoUrl'];
    //   } else {
    //     throw Exception('Failed to upload video: ${response.statusText}');
    //   }
    // } catch (e) {
    //   throw Exception('Failed to upload video: $e');
    // }
        return '';

  }

  // Upload reel thumbnail
  Future<String> uploadThumbnail(String thumbnailPath) async {
    // try {
    //   final formData = {
    //     'thumbnail': await MultipartFile.fromFile(
    //       thumbnailPath,
    //       filename: 'thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg',
    //     ),
    //   };

    //   final response = await apiClient.postMultipart('upload-reel-thumbnail', formData);
      
    //   if (response.statusCode == 200) {
    //     return response.body['data']['thumbnailUrl'];
    //   } else {
    //     throw Exception('Failed to upload thumbnail: ${response.statusText}');
    //   }
    // } catch (e) {
    //   throw Exception('Failed to upload thumbnail: $e');
    // }
    return '';
  }

  // Create new reel
  Future<void> createReel({
    required Map<String, dynamic> param,
    required Map<String, List<XFile>> filesMap,
    Function(double)? onProgress,
  }) async {
    try {
      final response = await apiClient.multiPartRequestWithDio(
        url: '/reels',
        filesMap: filesMap,
        fields: param,
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            // Calculate actual progress percentage
            final progress = sent / total;
            onProgress(progress);
            print('Upload Progress: ${(progress * 100).toStringAsFixed(1)}%');
          }
        },
        onReceiveProgress: (received, total) {
          // Optional: Handle download progress if needed
          final progress = received / total;
          print('Download Progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );

      if (response.statusCode == 200) {
        return response.body['data'];
      } else {
        throw Exception('Failed to create reel: ${response.statusText}');
      }
    } catch (e) {
      print('Upload Error: $e');
      rethrow; // Rethrow to handle in UI
    }
  }

  // Get reels with pagination
  Future<List<ReelData>> getReels({
    int start = 0,
    int limit = 10,
  }) async {
    try {
      final response = await apiClient.getData(UrlRes.generateReel, query: {
        'start': start.toString(),
        'limit': limit.toString(),
      });

      if (response.statusCode == 200) {
        final List<dynamic> reelsData = response.body['data'];
        return reelsData.map((data) => ReelData.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch reels: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Failed to fetch reels: $e');
    }
  }


  // Get For You reels
  Future<List<ReelData>> getForYouReels({Map<String, dynamic>? params = const {}}) async {
    try {


      final url = params!.containsKey('nearby') 
          ? UrlRes.nearByReels 
          : params.containsKey('following') 
              ? UrlRes.followingReels 
              : UrlRes.generateReel;
      final response = await apiClient.getData(
        url,
        query: params,
        handleError: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> reelsData = response.body['data'];
        return reelsData.map((data) => ReelData.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch for you reels: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Failed to fetch for you reels: $e');
    }
  }



  // Get For You reels
  Future<List<ReelData>> getNearByReels({Map<String, dynamic>? params}) async {
    Get.log('params: ${params}');
    try {

   final response = await apiClient.getData(
        'reels/nearby',
        query: params,
        handleError: false,
      );


      if (response.statusCode == 200) {
        final List<dynamic> reelsData = response.body['data'];
        return reelsData.map((data) => ReelData.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch near by reels: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Failed to fetch near by reels: $e');
    }
  }


  // Get user reels
  Future<List<ReelData>> getUserReels(int userId,int start) async {
          print('userIdmmmmmmm: $userId');

    try {
      final response = await apiClient.getData(
        'reels/user/$userId',
        query: {'reels_by_user': userId.toString(),'start': start.toString()},
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

    // Get user reels
  Future<ReelData> getUserReelsByID(int reelId,int start) async {
    try {
      final response = await apiClient.getData(
        'reel/$reelId',
        query: {'start': start.toString()},
      );

      if (response.statusCode == 200) {
        final reelsData = response.body['data'];
        return ReelData.fromJson(reelsData);
      } else {
        throw Exception('Failed to fetch user reels: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user reels: $e');
    }
  }

  // Delete reel
  Future<void> deleteReel(int reelId) async {
    try {
      final response = await apiClient.deleteData('reel/$reelId');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete reel: ${response.statusText}');
      }
    } catch (e) {
      throw Exception('Failed to delete reel: $e');
    }
  }

  // Toggle reel like
  Future<void> toggleReelLike(int reelId, bool isLiking) async {
    // try {
    //   final response = await apiClient.post(
    //     isLiking ? 'like-reel' : 'unlike-reel',
    //     {'reel_id': reelId},
    //   );

    //   if (response.statusCode != 200) {
    //     throw Exception('Failed to update reel like: ${response.statusText}');
    //   }
    // } catch (e) {
    //   throw Exception('Failed to update reel like: $e');
    // }
  }

  // Report reel
  Future<void> reportReel(Map<String, dynamic> params) async {
    final response = await apiClient.postData('/reels/report', params);
    if (response.statusCode != 200) {
      throw Exception('Failed to report reel: ${response.statusText}');
    }
  }

  // Increase reel view count
  Future<void> increaseReelViewCount(int reelId) async {
    final response = await apiClient.getData('/reels/$reelId/view');
    if (response.statusCode != 200) {
      throw Exception('Failed to increase reel view count: ${response.statusText}');
    }
  }
} 
