import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';

class PaymentRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  Future<Map<String, dynamic>> purchaseProperty(String propertyId, String paymentMethod, {String? signature}) async {
    try {
    final response = await apiClient.postData('properties/${propertyId}/payment', {
      'payment_method': paymentMethod,
      'signature': signature,
    });
    if (response.statusCode == 200) {
      return response.body['data'];
    } else {
        throw Exception(response.body['message'] ?? response.statusText ?? 'Failed to purchase property');
      }
    } catch (e) {
      throw Exception(e.toString() ?? 'Failed to purchase property');
    }
  }

  Future<Map<String, dynamic>> mintNft(String? propertyId, {String? walletAddress}) async {
    try {
      final response = await apiClient.postData('nfts/mint', {
        if (propertyId != null) 'property_id': propertyId,
        'wallet_address': walletAddress,
      });
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception(response.body['message'] ?? response.statusText ?? 'Failed to mint NFT');
    }
    } catch (e) {
      throw Exception(e.toString() ?? 'Failed to mint NFT');
    }
  }
} 