import 'package:homy/models/points/points_model.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';

class PointsRepository {
  final ApiClient _apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  Future<PointsData> getPointsDetails() async {
    final response = await _apiClient.getData('points/details');
    
    if (response.statusCode == 200) {
      return PointsData.fromJson(response.body['data']);
    } else {
      throw Exception('Failed to fetch points details');
    }
  }

  Future<PointsResponse> getPointsTransactions({
    int page = 1,
    int pageSize = 10,
    String timeFrame = 'all',
    String startDate = '',
    String endDate = '',
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'per_page': pageSize.toString(),
    };

    if (timeFrame != 'all') {
      queryParams['time_frame'] = timeFrame;
    }

    if (startDate.isNotEmpty && endDate.isNotEmpty) {
      queryParams['start_date'] = startDate;
      queryParams['end_date'] = endDate;
    }

    final response = await _apiClient.getData(
      'points/transactions',
      query: queryParams,
    );

    if (response.statusCode == 200) {
      return PointsResponse.fromJson(response.body);
    } else {
      throw Exception('Failed to fetch points transactions');
    }
  }

  Future<Map<String, dynamic>> redeemPoints({
    required int points,
    required String redemptionType,
    Map<String, dynamic>? additionalData,
  }) async {
    final Map<String, dynamic> data = {
      'points': points,
      'redemption_type': redemptionType,
    };

    if (additionalData != null) {
      data.addAll(additionalData);
    }

    final response = await _apiClient.postData(
      'points/redeem',
      data,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body['data'];
    } else {
      throw Exception(response.body['message'] ?? 'Failed to redeem points');
    }
  }

  Future<Map<String, dynamic>> getReferralCode() async {
    final response = await _apiClient.getData('points/referral-code');

    if (response.statusCode == 200) {
      return response.body['data'];
    } else {
      throw Exception('Failed to fetch referral code');
    }
  }

  Future<List<PointsActivity>> getAvailableActivities() async {
    final response = await _apiClient.getData('points/activities');

    if (response.statusCode == 200) {
      final List<dynamic> activities = response.body['data']['activities'];
      return activities.map((a) => PointsActivity.fromJson(a)).toList();
    } else {
      throw Exception('Failed to fetch available activities');
    }
  }

  Future<Map<String, dynamic>> getRedemptionOptions() async {
    final response = await _apiClient.getData('points/redemption-options');

    if (response.statusCode == 200) {
      return response.body['data'];
    } else {
      throw Exception('Failed to fetch redemption options');
    }
  }
} 