import 'package:homy/providers/api_client.dart';
import 'package:homy/models/dispute/dispute_model.dart';
import 'package:homy/models/dispute/dispute_message.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/constants.dart';

class DisputeRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);


  Future<Map<String, dynamic>> openDispute(String tourId, Map<String, dynamic> data, Map<String, List<XFile>>? filesMap) async {
    try{
           final response = await apiClient.multiPartRequestWeb(
        url: 'tour-requests/dispute/$tourId',
        fields: data,
        filesMap: filesMap ?? {},
      );
      // return response.body;

    //   final response = await apiClient.postData(
    //     'tour-requests/dispute/$tourId',
    //     {
    //     'reason': reason,
    //     // 'evidence': evidence,
    //   },handleError: false
    // );
    if(response.statusCode == 200){
      return response.body['data'];
    }
     if(response.statusCode == 400){
      throw response.body['message'];
    }
    else{
      throw Exception(response.statusText);
    }
    }
    catch(e){
      throw Exception(e);
    }
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

  Future<Dispute> getDispute(String disputeId) async {
    try {
      final response = await apiClient.getData('disputes/$disputeId');
      
      if (response.statusCode == 200) {
        return Dispute.fromJson(response.body['data']);
      }
      throw Exception(response.statusText);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<DisputeMessage>> getDisputeMessages(String disputeId) async {
    try {
      final response = await apiClient.getData('disputes/$disputeId/messages');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['data'];
        return data.map((json) => DisputeMessage.fromJson(json)).toList();
      }
      throw Exception(response.statusText);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<DisputeMessage> sendDisputeMessage(String disputeId, String message) async {
    try {
      final response = await apiClient.postData(
        'disputes/$disputeId/messages',
        {
          'message': message,
          'type': 'message',
        },
      );
      
      if (response.statusCode == 200) {
        return DisputeMessage.fromJson(response.body['data']['message']);
      }
      throw Exception(response.statusText);
    } catch (e) {
      throw Exception(e);
    }
  }
} 