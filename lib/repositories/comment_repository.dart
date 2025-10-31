import 'package:get/get.dart';
import 'package:homy/models/reels/comment_model.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';

class CommentRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  // Fetch comments for a reel
  Future<List<CommentData>> fetchComments(int reelId, {int start = 0, int limit = 5}) async {
    try {
      final response = await apiClient.getData(
        'reels/$reelId/comments',
        query: {
          'start': start.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> commentsData = response.body['data'];
        return commentsData.map((data) => CommentData.fromJson(data)).toList();
      } else {
        throw 'Failed to fetch comments: ${response.statusText}';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch comments: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Add a new comment
  Future<CommentData> addComment({
    required int userId,
    required int reelId,
    required String description,
    int? parentId,
  }) async {
    try {
      final response = await apiClient.postData(
        'reels/comments',
        {
          'user_id': userId,
          'reel_id': reelId,
          'description': description,
          if (parentId != null) 'reply_to_id': parentId,
        },
      );

      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommentData.fromJson(response.body['data']);
      } else {
        throw 'Failed to add comment: ${response.body['message']}';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add comment: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }




  // Add a new comment
  Future<CommentData> addReply({
    required int userId,
    required int replyToId,
    required String description,
  }) async {
    try {
      final response = await apiClient.postData(
        'reels/comments/reply',
        {
          'user_id': userId,
          'reply_to_id': replyToId,
          'description': description,
        },
      );

      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommentData.fromJson(response.body['data']);
      } else {
        throw 'Failed to add comment: ${response.body['message']}';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add comment: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Like/Unlike a comment
  Future<void> toggleCommentLike(int commentId) async {
    try {
      final response = await apiClient.postData(
        'comments/$commentId/toggle-like',
        {},
      );

      if (response.statusCode != 200) {
        throw 'Failed to update comment like: ${response.statusText}';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update comment like: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Delete a comment
  Future<void> deleteComment(int commentId) async {
    try {
      final response = await apiClient.deleteData('comments/$commentId');

      if (response.statusCode != 200) {
        throw 'Failed to delete comment: ${response.statusText}';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete comment: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }

  // Report a comment
  Future<void> reportComment(int commentId, String reason) async {
    try {
      final response = await apiClient.postData(
        'comments/$commentId/report',
        {'reason': reason},
      );

      if (response.statusCode != 200) {
        throw 'Failed to report comment: ${response.statusText}';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to report comment: $e',
        snackPosition: SnackPosition.TOP,
      );
      rethrow;
    }
  }
} 