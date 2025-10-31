import 'package:get/get.dart';
import 'package:homy/models/nft_property_model.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/utils/constants.dart';

class NFTMarketplaceService extends GetxService {
  static NFTMarketplaceService get to => Get.find();
  
  final ApiClient _apiClient = ApiClient(appBaseUrl: Constants.baseUrl);
  final SolanaWalletService _walletService = SolanaWalletService.to;

  @override
  void onInit() {
    super.onInit();
  }

  /// Purchase a property and initiate NFT minting
  /// 
  /// [property] - The NFT property to purchase
  /// [paymentMethod] - Payment method (e.g., 'solana', 'card', 'upi')
  /// 
  /// Returns a Map containing purchase result with transaction details
  Future<Map<String, dynamic>?> purchaseProperty({
    required NFTPropertyModel property,
    String paymentMethod = 'solana',
  }) async {
    try {
      if (!_walletService.isConnected.value) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Please connect your wallet first',
        ));
        return null;
      }

      // Prepare purchase request
      final requestData = {
        'property_id': property.mintAddress ,
        'wallet_address': _walletService.walletAddress.value,
        'payment_method': paymentMethod,
        'amount': property.metadata?['price'] ?? '0',
        'currency': 'INR',
        'property_data': {
          'title': property.nftName ?? 'Property NFT',
          'description': property.metadata?['description'] ?? property.metadata?['title'] ?? 'Property ownership certificate',
          'image_url': property.nftImage ?? '',
          'location': '${property.metadata?['city']}, ${property.metadata?['state']} ${property.metadata?['zip']}',
          'price': property.metadata?['price'] ?? '0' ,
        },
      };

      Get.log('Initiating property purchase: $requestData');

      // Call purchase API
      final response = await _apiClient.postData(
        'api/purchase',
        requestData,
        handleError: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.body['data'] ?? response.body;
        
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: 'Payment processed successfully!',
        ));
        
        Get.log('Purchase successful: $result');
        return result;
      } else {
        final errorMessage = response.body['message'] ?? 
                           response.body['data']?['message'] ?? 
                           'Failed to process payment';
        
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: errorMessage,
        ));
        
        Get.log('Purchase failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      Get.log('Error purchasing property: $e');
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Purchase failed: ${e.toString()}',
      ));
      return null;
    }
  }

  /// Mint NFT for a purchased property
  /// 
  /// [property] - The property to mint as NFT
  /// [purchaseId] - Purchase transaction ID
  /// 
  /// Returns a Map containing mint result with mint address and transaction signature
  Future<Map<String, dynamic>?> mintPropertyNFT({
    required NFTPropertyModel property,
    required String purchaseId,
  }) async {
    try {
      if (!_walletService.isConnected.value) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Please connect your wallet first',
        ));
        return null;
      }

      // Prepare NFT mint request
      final requestData = {
        'property_id': property.mintAddress,
        'purchase_id': purchaseId,
        'wallet_address': _walletService.walletAddress.value,
        'nft_metadata': {
              'name': property.nftName ?? 'Property NFT',
          'description': property.metadata?['description'] ?? property.metadata?['title'] ?? 'Property ownership certificate',
          'image': property.nftImage ?? '',
          'attributes': [
            {
              'trait_type': 'Property Type',
              'value': 'Real Estate',
            },
            {
              'trait_type': 'Location',
              'value': '${property.metadata?['city']}, ${property.metadata?['state']} ${property.metadata?['zip']}',
            },
            {
              'trait_type': 'Price',
              'value': property.metadata?['price'] ?? 'N/A',
            },
            {
              'trait_type': 'Minted Date',
              'value': DateTime.now().toIso8601String(),
            },
            {
              'trait_type': 'Certificate Type',
              'value': 'Property Ownership',
            },
          ],
          'external_url': 'https://urlinkproperty/${property.mintAddress}',
          'background_color': 'FFFFFF',
        },
        'collection': {
          'name': 'Homy Properties',
          'family': 'Real Estate NFTs',
        },
      };

      Get.log('Minting property NFT: $requestData');

      // Call mint API
      final response = await _apiClient.postData(
        'api/mint-nft',
        requestData,
        handleError: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.body['data'] ?? response.body;
        
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: 'NFT minted successfully!',
        ));
        
        Get.log('NFT mint successful: $result');
        return result;
      } else {
        final errorMessage = response.body['message'] ?? 
                           response.body['data']?['message'] ?? 
                           'Failed to mint NFT';
        
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: errorMessage,
        ));
        
        Get.log('NFT mint failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      Get.log('Error minting NFT: $e');
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'NFT minting failed: ${e.toString()}',
      ));
      return null;
    }
  }

  /// Complete purchase and minting process
  /// 
  /// [property] - The property to purchase and mint
  /// [paymentMethod] - Payment method
  /// 
  /// Returns a Map containing complete transaction details
  Future<Map<String, dynamic>?> completePurchaseAndMint({
    required NFTPropertyModel property,
    String paymentMethod = 'solana',
  }) async {
    try {
      // Step 1: Purchase property
      final purchaseResult = await purchaseProperty(
        property: property,
        paymentMethod: paymentMethod,
      );

      if (purchaseResult == null) {
        return null;
      }

      final purchaseId = purchaseResult['purchase_id'] ?? 
                        purchaseResult['transaction_id'] ?? 
                        DateTime.now().millisecondsSinceEpoch.toString();

      // Step 2: Mint NFT
      final mintResult = await mintPropertyNFT(
        property: property,
        purchaseId: purchaseId,
      );

      if (mintResult == null) {
        return null;
      }

      // Combine results
      final completeResult = {
        'purchase': purchaseResult,
        'mint': mintResult,
        'property_id': property.mintAddress,
        'wallet_address': _walletService.walletAddress.value,
        'completed_at': DateTime.now().toIso8601String(),
      };

      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: 'Property purchased and NFT minted successfully!',
      ));

      return completeResult;
    } catch (e) {
      Get.log('Error in complete purchase and mint: $e');
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Transaction failed: ${e.toString()}',
      ));
      return null;
    }
  }

  /// Get NFT properties for marketplace
  /// 
  /// [page] - Page number for pagination
  /// [limit] - Number of items per page
  /// [filter] - Optional filters (e.g., 'minted', 'preview', 'verified')
  /// 
  /// Returns a List of NFTPropertyModel objects
  Future<List<NFTPropertyModel>> getNFTProperties({
    int page = 1,
    int limit = 20,
    String? filter,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (filter != null) 'filter': filter,
      };

      final response = await _apiClient.getData(
        'api/nft-properties',
        query: queryParams,
        handleError: false, 
      );

      if (response.statusCode == 200) {
        final List<dynamic> propertiesData = response.body['data'] ?? [];
        
        return propertiesData.map((data) {
          return NFTPropertyModel.fromJson(data);
        }).toList();
      } else {
        Get.log('Failed to fetch NFT properties: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      Get.log('Error fetching NFT properties: $e');
      return [];
    }
  }

  /// Get user's owned NFTs
  /// 
  /// [walletAddress] - User's wallet address
  /// 
  /// Returns a List of NFTPropertyModel objects owned by the user
  Future<List<NFTPropertyModel>> getUserNFTs({
    String? walletAddress,
  }) async {
    try {
      final address = walletAddress ?? _walletService.walletAddress.value;

      final query = <String, String>{};
      if (address.isNotEmpty) {
        query['wallet_address'] = address;
      }

      final response = await _apiClient.getData(
        'nfts/user',
        query: query,
        handleError: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> nftsData = response.body['data']['nfts'] ?? [];
        // Get.log('nftsData: $nftsData');
        return nftsData.map((data) {
          return NFTPropertyModel.fromJson(data);
        }).toList();
      } else {
        Get.log('Failed to fetch user NFTs: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      Get.log('Error fetching user NFTs: $e');
      return [];
    }
  }

  /// Verify NFT ownership
  /// 
  /// [mintAddress] - NFT mint address
  /// [walletAddress] - Wallet address to verify ownership
  /// 
  /// Returns true if the wallet owns the NFT
  Future<bool> verifyNFTOwnership({
    required String mintAddress,
    String? walletAddress,
  }) async {
    try {
      final address = walletAddress ?? _walletService.walletAddress.value;
      
      if (address.isEmpty) {
        return false;
      }

      final response = await _apiClient.getData(
        'nfts/verify-ownership',
        query: {
          'mint_address': mintAddress,
          'wallet_address': address,
        },
        handleError: false,
      );

      if (response.statusCode == 200) {
        return response.body['data']?['is_owner'] ?? false;
      } else {
        Get.log('Failed to verify NFT ownership: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Get.log('Error verifying NFT ownership: $e');
      return false;
    }
  }

  /// Get NFT transaction history
  /// 
  /// [mintAddress] - NFT mint address
  /// 
  /// Returns a List of transaction records
  Future<List<Map<String, dynamic>>> getNFTTransactionHistory({
    required String mintAddress,
  }) async {
    try {
      final response = await _apiClient.getData(
        'api/nft-transaction-history',
          query: {'mint_address': mintAddress},
        handleError: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> transactions = response.body['data'] ?? [];
        return transactions.cast<Map<String, dynamic>>();
      } else {
        Get.log('Failed to fetch NFT transaction history: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      Get.log('Error fetching NFT transaction history: $e');
      return [];
    }
  }

  /// Update property NFT status
  /// 
  /// [propertyId] - Property ID
  /// [isMinted] - Whether the property is minted
  /// [mintAddress] - Mint address if minted
  /// [transactionSignature] - Transaction signature
  /// 
  /// Returns true if update was successful
  Future<bool> updatePropertyNFTStatus({
    required int propertyId,
    required bool isMinted,
    String? mintAddress,
    String? transactionSignature,
  }) async {
    try {
      final requestData = {
        'property_id': propertyId,
        'is_minted': isMinted,
        if (mintAddress != null) 'mint_address': mintAddress,
        if (transactionSignature != null) 'transaction_signature': transactionSignature,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _apiClient.putData(
        'api/update-property-nft-status',
        requestData,
        handleError: false,
      );

      if (response.statusCode == 200) {
        Get.log('Property NFT status updated successfully');
        return true;
      } else {
        Get.log('Failed to update property NFT status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Get.log('Error updating property NFT status: $e');
      return false;
    }
  }
}
