import 'package:homy/models/earning.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';

class EarningsRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  Future<EarningResponse> getEarnings({
    int page = 1,
    int perPage = 10,
    String? timeFrame,
    String? status,
  }) async {
    try {
      final query = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (timeFrame != null) {
        query['time_frame'] = timeFrame;
      }

      if (status != null) {
        query['status'] = status;
      }

      final response = await apiClient.getData('/tour-earnings', query: query);
      if (response.body['status'] == 200) {
        return EarningResponse.fromJson(response.body['data']);
      } else {
        throw Exception(response.body['message'] ?? 'Failed to fetch earnings');
      }
    } catch (e) {
      throw Exception('Error fetching earnings: $e');
    }
  }

  Future<Map<String, dynamic>> getTotalEarnings() async {
    try {
      final response = await apiClient.getData('/tour-earnings/total');
      if (response.statusCode == 200) {
        return response.body['data']['totals'];
      } else {
        throw Exception(response.body['message'] ?? 'Failed to fetch total earnings');
      }
    } catch (e) {
      throw Exception('Error fetching total earnings: $e');
    }
  }
} 