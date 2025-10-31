import 'package:homy/providers/api_client.dart';
import 'package:homy/models/dispute/dispute_model.dart';
import 'package:homy/utils/html_type.dart';

import '../utils/constants.dart';

class HtmlRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);


  Future<Map<String, dynamic>> getHtmlText(HtmlType htmlType) async {

      final response = await apiClient.getData(
      htmlType == HtmlType.termsAndCondition ? Constants.termsAndConditionUri
          : htmlType == HtmlType.privacyPolicy ? Constants.privacyPolicyUri : htmlType == HtmlType.aboutUs
          ? Constants.aboutUsUri : htmlType == HtmlType.shippingPolicy ? Constants.shippingPolicyUri
          : htmlType == HtmlType.cancellation ? Constants.cancellationUri : Constants.refundUri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
    );

    return response.body['data'];
  }

  Future<Map<String, dynamic>> resolveDispute(String tourId, int resolution) async {
    final response = await apiClient.postData(
      'tour-requests/dispute/$tourId/resolve',
      {
        'resolution': resolution,
      },
    );
    return response.body['data'];
  }

  Future<Map<String, dynamic>> confirmTourCompletion(String tourId) async {
    final response = await apiClient.postData(
      'tour-requests/confirm-completion/$tourId',
      {},
    );
    return response.body['data'];
  }

  Future<List<Dispute>> getDisputes() async {
    try {
      final response = await apiClient.getData('disputes');
      
      if (response.statusCode == 200) {
        
        final List<dynamic> data = response.body['data'];
        return data.map((json) => Dispute.fromJson(json)).toList();
      }
      throw Exception(response.statusText);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>> getDisputeDetails(String disputeId) async {
    try {
      final response = await apiClient.getData('tour-requests/disputes/$disputeId');
      
      if (response.statusCode == 200) {
        return response.body['data'];
      }
      
      throw Exception(response.statusText);
    } catch (e) {
      throw Exception(e);
    }
  }
} 