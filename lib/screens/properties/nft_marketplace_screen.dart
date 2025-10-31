import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/nft_property_model.dart';
import 'package:homy/services/nft_marketplace_service.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:homy/screens/properties/widgets/nft_property_card.dart';
import 'package:homy/screens/properties/widgets/wallet_connection_widget.dart';
import 'package:homy/screens/properties/widgets/buy_confirmation_modal.dart';
import 'package:homy/screens/properties/widgets/minting_progress_dialog.dart';
import 'package:homy/screens/properties/widgets/mint_success_screen.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/common/ui.dart';

class NFTMarketplaceScreen extends StatefulWidget {
  final int initialTab; // 0: Marketplace, 1: My NFTs
  const NFTMarketplaceScreen({Key? key, this.initialTab = 0}) : super(key: key);

  @override
  State<NFTMarketplaceScreen> createState() => _NFTMarketplaceScreenState();
}

class _NFTMarketplaceScreenState extends State<NFTMarketplaceScreen>
    with TickerProviderStateMixin {
  final NFTMarketplaceService _marketplaceService = NFTMarketplaceService.to;
  final SolanaWalletService _walletService = SolanaWalletService.to;
  
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  List<NFTPropertyModel> _properties = [];
  List<NFTPropertyModel> _userNFTs = [];
  bool _isLoading = false;
  bool _isLoadingUserNFTs = false;
  String _selectedFilter = 'all';
  
  final List<String> _filters = [
    'all',
    'preview',
    'minted',
    'verified',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab.clamp(0, 1));
    // _loadProperties();
    _loadUserNFTs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final properties = await _marketplaceService.getNFTProperties(
        filter: _selectedFilter == 'all' ? null : _selectedFilter,
      );
      
      setState(() {
        _properties = properties;
      });
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to load properties: ${e.toString()}',
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserNFTs() async {
    setState(() {
      _isLoadingUserNFTs = true;
    });

    try {
      final nfts = await _marketplaceService.getUserNFTs();
      
      setState(() {
        _userNFTs = nfts;
      });
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to load your NFTs: ${e.toString()}',
      ));
    } finally {
      setState(() {
        _isLoadingUserNFTs = false;
      });
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _loadProperties();
  }

  void _onBuyNowPressed(NFTPropertyModel property) {
    if (!_walletService.isConnected.value) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Please connect your wallet first',
      ));
      return;
    }

    Get.dialog(
      BuyConfirmationModal(
        property: property,
        onConfirm: () => _handlePurchase(property),
      ),
    );
  }

  Future<void> _handlePurchase(NFTPropertyModel property) async {
    Get.back(); // Close confirmation modal
    
    // Show minting dialog
    Get.dialog(
      MintingProgressDialog(
        property: property,
        onComplete: () => _handleMintingComplete(property),
        onError: () => _handleMintingError(),
      ),
    );

    try {
      // Complete purchase and minting
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
        setState(() {
          final index = _properties.indexWhere((p) => p.mintAddress == property.mintAddress);
          if (index != -1) {
            _properties[index] = updatedProperty;
          }
        });

        // Close minting dialog and show success screen
        Get.back();
        _showSuccessScreen(updatedProperty, result);
      } else {
        Get.back(); // Close minting dialog
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Purchase failed. Please try again.',
        ));
      }
    } catch (e) {
      Get.back(); // Close minting dialog
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Purchase failed: ${e.toString()}',
      ));
    }
  }

  void _handleMintingComplete(NFTPropertyModel property) {
    // This will be called by the minting dialog
  }

  void _handleMintingError() {
    Get.showSnackbar(CommonUI.ErrorSnackBar(
      message: 'Minting failed. Please try again.',
    ));
  }

  void _showSuccessScreen(NFTPropertyModel property, Map<String, dynamic> result) {
    Get.to(
      () => MintSuccessScreen(
        property: property,
        mintAddress: result['mint']?['mint_address'] ?? '',
        transactionSignature: result['mint']?['transaction_signature'] ?? '',
        onContinue: () {
          Get.back();
          _loadProperties();
          _loadUserNFTs();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'NFT Property Marketplace',
            style: MyTextStyle.productBold(size: 20),
        ),
        actions: [
          WalletStatusIndicator(
            onTap: () => _walletService.connectWallet(),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Marketplace'),
            Tab(text: 'My NFTs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarketplaceTab(),
          _buildMyNFTsTab(),
        ],
      ),
    );
  }

  Widget _buildMarketplaceTab() {
    return Column(
      children: [
        // Wallet connection widget
        Padding(
          padding: const EdgeInsets.all(16),
          child: WalletConnectionWidget(
            onConnectPressed: () => _walletService.connectWallet(),
          ),
        ),
        
        // Filter chips
        _buildFilterChips(),
        
        // Properties list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _properties.isEmpty
                  ? _buildEmptyState()
                  : _buildPropertiesList(),
        ),
      ],
    );
  }

  Widget _buildMyNFTsTab() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Get.theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Your NFT Collection',
                style: MyTextStyle.productBold(size: 18),
              ),
            ],
          ),
        ),
        
        // User NFTs list
        Expanded(
          child: _isLoadingUserNFTs
              ? const Center(child: CircularProgressIndicator())
              : _userNFTs.isEmpty
                  ? _buildEmptyNFTsState()
                  : _buildUserNFTsList(),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterLabel(filter)),
              selected: isSelected,
              onSelected: (selected) => _onFilterChanged(filter),
              selectedColor: Get.theme.colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Get.theme.colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'All';
      case 'preview':
        return 'Preview';
      case 'minted':
        return 'Minted';
      case 'verified':
        return 'Verified';
      default:
        return filter;
    }
  }

  Widget _buildPropertiesList() {
    return RefreshIndicator(
      onRefresh: _loadProperties,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _properties.length,
        itemBuilder: (context, index) {
          final property = _properties[index];
          return CompactNFTPropertyCard(
            property: property,
            onTap: () => _showPropertyDetails(property),
            onBuyNow: () => _onBuyNowPressed(property),
          );
        },
      ),
    );
  }

  Widget _buildUserNFTsList() {
    return RefreshIndicator(
      onRefresh: _loadUserNFTs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userNFTs.length,
        itemBuilder: (context, index) {
          final nft = _userNFTs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: NFTPropertyCard(
              property: nft,
              onTap: () => _showPropertyDetails(nft),
              showBuyButton: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined,
            size: 80,
            color: Get.theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Properties Found',
            style: MyTextStyle.productBold(size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: MyTextStyle.productRegular(
              size: 14,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadProperties,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNFTsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Get.theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No NFTs Yet',
            style: MyTextStyle.productBold(size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Purchase properties to start building your NFT collection',
            style: MyTextStyle.productRegular(
              size: 14,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _tabController.animateTo(0);
            },
            child: const Text('Browse Properties'),
          ),
        ],
      ),
    );
  }

  void _showPropertyDetails(NFTPropertyModel property) {
    // In a real app, you would navigate to a detailed property view
    Get.dialog(
      AlertDialog(
        title: Text(property.nftName ?? 'Property Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ${property.metadata?['price'] ?? '0'}'),
            Text('Location: ${property.metadata?['city']}, ${property.metadata?['state']} ${property.metadata?['zip'] }'),
            Text('Status: ${property.nftState}'),
            if (property.isMinted) ...[
              Text('Mint Address: ${property.shortMintAddress}'),
              Text('Owner: ${property.ownerWalletAddress}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          if (!property.isMinted)
            ElevatedButton(
              onPressed: () {
                Get.back();
                _onBuyNowPressed(property);
              },
              child: const Text('Buy Now'),
            ),
        ],
      ),
    );
  }
}
