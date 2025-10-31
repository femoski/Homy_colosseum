import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:homy/screens/properties/controllers/nft_marketplace_controller.dart';
import 'package:homy/screens/properties/widgets/nft_property_card.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:homy/services/nft_marketplace_service.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/screens/properties/widgets/nft_grid_shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MyNFTsScreen extends StatefulWidget {
  const MyNFTsScreen({Key? key}) : super(key: key);

  @override
  State<MyNFTsScreen> createState() => _MyNFTsScreenState();
}

class _MyNFTsScreenState extends State<MyNFTsScreen> {
  final NFTMarketplaceController _controller = Get.find<NFTMarketplaceController>();
  final SolanaWalletService _walletService = SolanaWalletService.to;
  final NFTMarketplaceService _marketplaceService = NFTMarketplaceService.to;

  @override
  void initState() {
    super.initState();
    _controller.loadUserNFTs();
  }

  Future<void> _refresh() async {
    await _controller.loadUserNFTs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My NFTs',
          style: MyTextStyle.productBold(size: 20),
        ),
        actions: [
          IconButton(
            onPressed: _controller.loadUserNFTs,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        // if (!_walletService.isConnected.value) {
        //   return _buildConnectWallet();
        // }

        if (_controller.isLoadingUserNFTs.value) {
          return const NFTGridShimmer(itemCount: 8);
        }

        final nfts = _controller.getMintedNFTs();
        if (nfts.isEmpty) return _buildEmptyState();

        return RefreshIndicator(
          onRefresh: _refresh,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: nfts.length,
            itemBuilder: (context, index) {
              final nft = nfts[index];
              return CompactNFTPropertyCard(
                property: nft,
                onTap: () => _showNFTActions(nft),
                onBuyNow: null,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildConnectWallet() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 72,
              color: Get.theme.colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Connect your wallet to view your NFTs',
              style: MyTextStyle.productBold(size: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We’ll show NFTs minted to your Solana wallet',
              style: MyTextStyle.productRegular(
                size: 14,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await _walletService.connectWallet();
                  _controller.loadUserNFTs();
                } catch (e) {
                  Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
                }
              },
              icon: const Icon(Icons.link),
              label: const Text('Connect Wallet'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 72,
              color: Get.theme.colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No NFTs found',
              style: MyTextStyle.productBold(size: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Purchase properties to start building your NFT collection',
              style: MyTextStyle.productRegular(
                size: 14,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Get.toNamed('/nft-marketplace'),
              child: const Text('Browse Marketplace'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNFTActions(nft) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nft.nftName ?? 'NFT',
                        style: MyTextStyle.productBold(size: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (nft.isVerified)
                      const Icon(Icons.verified, color: Colors.blue),
                  ],
                ),
                const SizedBox(height: 8),
                if (nft.mintAddress != null && nft.mintAddress.isNotEmpty) ...[
                  Text(
                    nft.shortMintAddress,
                    style: MyTextStyle.productRegular(
                      size: 13,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (nft.mintAddress != null && nft.mintAddress.isNotEmpty) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.verified_user),
                    title: const Text('Verify on-chain'),
                    subtitle: const Text('Check if your wallet owns this NFT'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final isOwner = await _marketplaceService.verifyNFTOwnership(
                        mintAddress: nft.mintAddress,
                      );
                      if (isOwner) {
                        Get.showSnackbar(CommonUI.SuccessSnackBar(
                          message: 'Ownership verified: You own this NFT',
                        ));
                      } else {
                        Get.showSnackbar(CommonUI.ErrorSnackBar(
                          message: 'Ownership not verified for this wallet',
                        ));
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.open_in_new),
                    title: const Text('View on Solana Explorer'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final url = nft.solanaExplorerUrl;
                      if (url != null) {
                        await launchUrlString(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.copy),
                    title: const Text('Copy mint address'),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: nft.mintAddress));
                      Navigator.of(context).pop();
                      Get.showSnackbar(CommonUI.SuccessSnackBar(
                        message: 'Mint address copied',
                      ));
                    },
                  ),
                ] else ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Not minted yet'),
                    subtitle: const Text('Mint to enable on-chain verification'),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}


