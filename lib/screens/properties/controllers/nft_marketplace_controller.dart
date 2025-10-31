import 'package:get/get.dart';
import 'package:homy/models/nft_property_model.dart';
import 'package:homy/services/nft_marketplace_service.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:homy/common/ui.dart';

class NFTMarketplaceController extends GetxController {
  final NFTMarketplaceService _marketplaceService = NFTMarketplaceService.to;
  final SolanaWalletService _walletService = SolanaWalletService.to;

  // Observable state
  final RxList<NFTPropertyModel> properties = <NFTPropertyModel>[].obs;
  final RxList<NFTPropertyModel> userNFTs = <NFTPropertyModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingUserNFTs = false.obs;
  final RxString selectedFilter = 'all'.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  // Filter options
  final List<String> filters = [
    'all',
    'preview',
    'minted',
    'verified',
  ];

  @override
  void onInit() {
    super.onInit();
    // loadProperties();
    loadUserNFTs();
  }

  /// Load properties from API
  Future<void> loadProperties({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
    }

    if (isLoading.value || !hasMoreData.value) return;

    isLoading.value = true;

    try {
      final newProperties = await _marketplaceService.getNFTProperties(
        page: currentPage.value,
        limit: 20,
        filter: selectedFilter.value == 'all' ? null : selectedFilter.value,
      );

      if (refresh) {
        properties.clear();
      }

      if (newProperties.isNotEmpty) {
        properties.addAll(newProperties);
        currentPage.value++;
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to load properties: ${e.toString()}',
      ));
    } finally {
      isLoading.value = false;
    }
  }

  /// Load user's NFTs
  Future<void> loadUserNFTs() async {
    isLoadingUserNFTs.value = true;

    try {
      final nfts = await _marketplaceService.getUserNFTs();
            userNFTs.assignAll(nfts);
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to load your NFTs: ${e.toString()}',
      ));
    } finally {
      isLoadingUserNFTs.value = false;
    }
  }

  /// Change filter and reload properties
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    loadProperties(refresh: true);
  }

  /// Purchase a property
  Future<void> purchaseProperty(NFTPropertyModel property) async {
    if (!_walletService.isConnected.value) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Please connect your wallet first',
      ));
      return;
    }

    try {
      final result = await _marketplaceService.completePurchaseAndMint(
        property: property,
      );

      if (result != null) {
        // Update property status locally
        final updatedProperty = property.copyWithNFT(
          isMinted: true,
          mintAddress: result['mint']?['mint_address'],
          transactionSignature: result['mint']?['transaction_signature'],
          ownerWalletAddress: _walletService.walletAddress.value,
          mintedAt: DateTime.now(),
        );

        // Update local state
        final index = userNFTs.indexWhere((p) => p.mintAddress == property.mintAddress);
        if (index != -1) {
          userNFTs[index] = updatedProperty;
        }

        // Add to user NFTs
        userNFTs.add(updatedProperty);

        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: 'Property purchased and NFT minted successfully!',
        ));
      } else {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Purchase failed. Please try again.',
        ));
      }
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Purchase failed: ${e.toString()}',
      ));
    }
  }

  /// Get properties by filter
  List<NFTPropertyModel> getFilteredProperties() {
    switch (selectedFilter.value) {
      case 'preview':
        return properties.where((p) => !p.isMinted).toList();
      case 'minted':
        return properties.where((p) => p.isMinted).toList();
      case 'verified':
        return properties.where((p) => p.isVerified).toList();
      default:
        return properties;
    }
  }

  /// Get user's minted NFTs
  List<NFTPropertyModel> getMintedNFTs() {
    return userNFTs;
  }

  /// Get user's preview properties
  List<NFTPropertyModel> getPreviewProperties() {
    return userNFTs.where((nft) => !nft.isMinted).toList();
  }

  /// Search properties
  List<NFTPropertyModel> searchProperties(String query) {
    if (query.isEmpty) return getFilteredProperties();
    
    final lowercaseQuery = query.toLowerCase();
    return getFilteredProperties().where((property) {
      return (property.nftName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (property.metadata?['city']?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (property.metadata?['state']?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (property.metadata?['zip']?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Sort properties
  void sortProperties(String sortBy) {
    switch (sortBy) {
      case 'price_low_to_high':
        properties.sort((a, b) {
          final priceA = double.tryParse(a.metadata?['price'] ?? '0') ?? 0;
          final priceB = double.tryParse(b.metadata?['price'] ?? '0') ?? 0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_high_to_low':
        properties.sort((a, b) {
          final priceA = double.tryParse(a.metadata?['price'] ?? '0') ?? 0;
          final priceB = double.tryParse(b.metadata?['price'] ?? '0') ?? 0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'newest':
        properties.sort((a, b) {
          final dateA = DateTime.tryParse(a.metadata?['created_at'] ?? '') ?? DateTime(1970);
          final dateB = DateTime.tryParse(b.metadata?['created_at'] ?? '') ?? DateTime(1970);
          return dateB.compareTo(dateA);
        });
        break;
      case 'oldest':
        properties.sort((a, b) {
          final dateA = DateTime.tryParse(a.metadata?['created_at'] ?? '') ?? DateTime(1970);
          final dateB = DateTime.tryParse(b.metadata?['created_at'] ?? '') ?? DateTime(1970);
          return dateA.compareTo(dateB);
        });
        break;
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadProperties(refresh: true),
      loadUserNFTs(),
    ]);
  }

  /// Load more properties (for pagination)
  Future<void> loadMoreProperties() async {
    if (!isLoading.value && hasMoreData.value) {
      await loadProperties();
    }
  }

  /// Get property statistics
  Map<String, int> getPropertyStats() {
    final allProperties = properties;
    return {
      'total': allProperties.length,
      'preview': allProperties.where((p) => !p.isMinted).length,
      'minted': allProperties.where((p) => p.isMinted).length,
      'verified': allProperties.where((p) => p.isVerified).length,
    };
  }

  /// Get user NFT statistics
  Map<String, int> getUserNFTStats() {
    final allUserNFTs = userNFTs;
    return {
      'total': allUserNFTs.length,
      'minted': allUserNFTs.where((nft) => nft.isMinted).length,
      'preview': allUserNFTs.where((nft) => !nft.isMinted).length,
      'verified': allUserNFTs.where((nft) => nft.isVerified).length,
    };
  }

  /// Check if user owns a property
  bool isPropertyOwnedByUser(NFTPropertyModel property) {
    if (!_walletService.isConnected.value) return false;
    
    return property.ownerWalletAddress == _walletService.walletAddress.value;
  }

  /// Get properties owned by user
  List<NFTPropertyModel> getPropertiesOwnedByUser() {
    if (!_walletService.isConnected.value) return [];
    
    final userAddress = _walletService.walletAddress.value;
    return userNFTs.where((p) => p.ownerWalletAddress == userAddress).toList();
  }

  /// Clear all data
  void clearData() {
    properties.clear();
    userNFTs.clear();
    currentPage.value = 1;
    hasMoreData.value = true;
    selectedFilter.value = 'all';
  }
}
