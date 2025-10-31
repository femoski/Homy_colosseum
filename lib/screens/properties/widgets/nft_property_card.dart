import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:homy/models/nft_property_model.dart';
import 'package:homy/utils/my_text_style.dart';
// import 'package:homy/services/solana_wallet_service.dart';
// import 'package:homy/common/ui.dart';

class NFTPropertyCard extends StatelessWidget {
  final NFTPropertyModel property;
  final VoidCallback? onTap;
  final VoidCallback? onBuyNow;
  final bool showBuyButton;

  const NFTPropertyCard({
    Key? key,
    required this.property,
    this.onTap,
    this.onBuyNow,
    this.showBuyButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Get.theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with NFT badge
            _buildImageSection(),
            
            // Content section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and verified badge
                  _buildTitleSection(),
                  
                  const SizedBox(height: 8),
                  
                  // Price and NFT state
                  _buildPriceSection(),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  _buildLocationSection(),
                  
                  const SizedBox(height: 12),
                  
                  // Buy button
                  if (showBuyButton) _buildBuyButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Property image
        Container(
          height: 200,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: property.nftImage ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) {
              final isDark = Get.theme.brightness == Brightness.dark;
              final base = isDark
                  ? Get.theme.colorScheme.surfaceVariant.withOpacity(0.24)
                  : Get.theme.colorScheme.surfaceVariant.withOpacity(0.45);
              final highlight = isDark
                  ? Get.theme.colorScheme.onSurface.withOpacity(0.08)
                  : Get.theme.colorScheme.onSurface.withOpacity(0.08);
              return Shimmer.fromColors(
                baseColor: base,
                highlightColor: highlight,
                child: Container(
                  color: Get.theme.colorScheme.surface,
                ),
              );
            },
            errorWidget: (context, url, error) => Container(
              color: Get.theme.colorScheme.surface,
              child: Icon(
                Icons.home,
                size: 50,
                color: Get.theme.colorScheme.primary.withOpacity(0.5),
              ),
            ),
          ),
        ),
        
        // NFT state badge
        Positioned(
          top: 12,
          left: 12,
          child: _buildNFTStateBadge(),
        ),
        
        // Verified badge
        if (property.isVerified)
          Positioned(
            top: 12,
            right: 12,
            child: _buildVerifiedBadge(),
          ),
        
        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNFTStateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: property.isMinted 
            ? Colors.green.withOpacity(0.9)
            : Colors.orange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            property.isMinted ? Icons.check_circle : Icons.visibility,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            property.nftState,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.verified,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            property.nftName ?? 'Unknown NFT',
            style: MyTextStyle.gilroySemiBold(
              size: 16,
              color: Get.theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (property.isVerified) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.verified,
            size: 16,
            color: Colors.blue,
          ),
        ],
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          property.metadata?['price'] ?? '0',
          style: MyTextStyle.productBold(
            size: 18,
            color: Get.theme.colorScheme.primary,
          ),
        ),
        if (property.isMinted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'NFT Minted',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 16,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${property.metadata?['city'] ?? ''}, ${property.metadata?['state'] ?? ''} ${property.metadata?['zip'] ?? ''}',
            style: MyTextStyle.productRegular(
              size: 14,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBuyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: property.isMinted ? null : onBuyNow,
        style: ElevatedButton.styleFrom(
          backgroundColor: property.isMinted 
              ? Colors.grey.withOpacity(0.3)
              : Get.theme.colorScheme.primary,
          foregroundColor: property.isMinted 
              ? Colors.grey
              : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: property.isMinted ? 0 : 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (property.isMinted) ...[
              const Icon(Icons.check_circle, size: 18),
              const SizedBox(width: 8),
              const Text('Already Minted'),
            ] else ...[
              const Icon(Icons.shopping_cart, size: 18),
              const SizedBox(width: 8),
              const Text('Buy Now'),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact NFT Property Card for grid layouts
class CompactNFTPropertyCard extends StatelessWidget {
  final NFTPropertyModel property;
  final VoidCallback? onTap;
  final VoidCallback? onBuyNow;

  const CompactNFTPropertyCard({
    Key? key,
    required this.property,
    this.onTap,
    this.onBuyNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Get.theme.colorScheme.surface.withOpacity(0.9),
                Get.theme.colorScheme.surfaceVariant.withOpacity(0.6),
              ],
            ),
            border: Border.all(
              color: Get.theme.colorScheme.outline.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: property.nftImage ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) {
                            final isDark = Get.theme.brightness == Brightness.dark;
                            final base = isDark
                                ? Get.theme.colorScheme.surfaceVariant.withOpacity(0.24)
                                : Get.theme.colorScheme.surfaceVariant.withOpacity(0.45);
                            final highlight = isDark
                                ? Get.theme.colorScheme.onSurface.withOpacity(0.08)
                                : Get.theme.colorScheme.onSurface.withOpacity(0.08);
                            return Shimmer.fromColors(
                              baseColor: base,
                              highlightColor: highlight,
                              child: Container(
                                color: Get.theme.colorScheme.surface,
                              ),
                            );
                          },
                          errorWidget: (context, url, error) => Container(
                            color: Get.theme.colorScheme.surface,
                            child: Icon(
                              Icons.home,
                              size: 30,
                              color: Get.theme.colorScheme.primary.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 8,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: property.isMinted
                                    ? Colors.green.withOpacity(0.95)
                                    : Colors.orange.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    property.isMinted ? Icons.check_circle : Icons.visibility,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    property.nftState,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (property.isVerified)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.95),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.55),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                property.nftName ?? 'Unknown NFT',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if ((property.mintAddress ?? '').isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.token, size: 12, color: Colors.white70),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        property.shortMintAddress,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Expanded(
                //   flex: 2,
                //   child: Padding(
                //     padding: const EdgeInsets.all(12.0),
                //     child: Builder(
                //       builder: (_) {
                //         final walletService = SolanaWalletService.to;
                //         final bool isConnected = walletService.isConnected.value;
                //         return InkWell(
                //           borderRadius: BorderRadius.circular(12),
                //           onTap: () async {
                //             if (!isConnected) {
                //               try {
                //                 await walletService.connectWallet();
                //                 Get.showSnackbar(CommonUI.SuccessSnackBar(
                //                   message: 'Wallet connected',
                //                 ));
                //               } catch (e) {
                //                 Get.showSnackbar(CommonUI.ErrorSnackBar(
                //                   message: e.toString(),
                //                 ));
                //               }
                //             } else {
                //               if (onTap != null) onTap!();
                //             }
                //           },
                //           child: Container(
                //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(12),
                //               gradient: LinearGradient(
                //                 begin: Alignment.topLeft,
                //                 end: Alignment.bottomRight,
                //                 colors: [
                //                   Get.theme.colorScheme.primary.withOpacity(0.10),
                //                   Get.theme.colorScheme.secondary.withOpacity(0.08),
                //                 ],
                //               ),
                //               border: Border.all(
                //                 color: Get.theme.colorScheme.primary.withOpacity(0.15),
                //               ),
                //             ),
                //             child: Row(
                //               children: [
                //                 Icon(
                //                   isConnected
                //                       ? Icons.verified_user
                //                       : Icons.account_balance_wallet_outlined,
                //                   size: 18,
                //                   color: Get.theme.colorScheme.primary,
                //                 ),
                //                 const SizedBox(width: 8),
                //                 Expanded(
                //                   child: Column(
                //                     mainAxisSize: MainAxisSize.min,
                //                     crossAxisAlignment: CrossAxisAlignment.start,
                //                     children: [
                //                       Text(
                //                         isConnected
                //                             ? (property.isMinted
                //                                 ? 'Tap to view on-chain actions'
                //                                 : 'Not minted yet')
                //                             : 'Connect wallet to verify and manage NFT',
                //                         maxLines: 1,
                //                         overflow: TextOverflow.ellipsis,
                //                         style: MyTextStyle.productBold(
                //                           size: 12,
                //                           color: Get.theme.colorScheme.onSurface,
                //                         ),
                //                       ),
                //                       const SizedBox(height: 2),
                //                       Text(
                //                         isConnected
                //                             ? ((property.mintAddress ?? '').isNotEmpty
                //                                 ? property.shortMintAddress
                //                                 : 'No mint address yet')
                //                             : 'We’ll verify ownership and show explorer links',
                //                         maxLines: 1,
                //                         overflow: TextOverflow.ellipsis,
                //                         style: MyTextStyle.productRegular(
                //                           size: 11,
                //                           color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //                 const SizedBox(width: 8),
                //                 Icon(
                //                   Icons.chevron_right,
                //                   size: 18,
                //                   color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         );
                //       },
                //     ),
                //   ),
                // ),
                // Expanded(
                //   flex: 2,
                //   child: Padding(
                //     padding: const EdgeInsets.all(6.0),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Row(
                //           children: [
                //             Expanded(
                //               child: Text(
                //                 property.displayPrice,
                //                 maxLines: 1,
                //                 overflow: TextOverflow.ellipsis,
                //                 style: MyTextStyle.productBold(
                //                   size: 16,
                //                   color: Get.theme.colorScheme.primary,
                //                 ),
                //               ),
                //             ),
                //             if (property.isMinted)
                //               Container(
                //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //                 decoration: BoxDecoration(
                //                   color: Colors.green.withOpacity(0.12),
                //                   borderRadius: BorderRadius.circular(12),
                //                   border: Border.all(
                //                     color: Colors.green.withOpacity(0.25),
                //                   ),
                //                 ),
                //                 child: Text(
                //                   'Minted',
                //                   style: TextStyle(
                //                     color: Colors.green.shade700,
                //                     fontSize: 10,
                //                     fontWeight: FontWeight.w700,
                //                   ),
                //                 ),
                //               ),
                //           ],
                //         ),
                //         const SizedBox(height: 6),
                //         Row(
                //           children: [
                //             Icon(
                //               Icons.location_on,
                //               size: 12,
                //               color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                //             ),
                //             const SizedBox(width: 4),
                //             Expanded(
                //               child: Text(
                //                 '${property.city ?? ''}, ${property.state ?? ''}',
                //                 maxLines: 1,
                //                 overflow: TextOverflow.ellipsis,
                //                 style: MyTextStyle.productRegular(
                //                   size: 12,
                //                   color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //         // const Spacer(),
                //         // SizedBox(
                //         //   width: double.infinity,
                //         //   height: 34,
                //         //   child: ElevatedButton(
                //         //     onPressed: property.isMinted ? onTap : onBuyNow,
                //         //     style: ElevatedButton.styleFrom(
                //         //       backgroundColor: property.isMinted
                //         //           ? Get.theme.colorScheme.surfaceVariant
                //         //           : Get.theme.colorScheme.primary,
                //         //       foregroundColor: property.isMinted
                //         //           ? Get.theme.colorScheme.onSurface.withOpacity(0.8)
                //         //           : Colors.white,
                //         //       shape: RoundedRectangleBorder(
                //         //         borderRadius: BorderRadius.circular(10),
                //         //       ),
                //         //       elevation: 0,
                //         //     ),
                //         //     child: Row(
                //         //       mainAxisAlignment: MainAxisAlignment.center,
                //         //       children: [
                //         //         Icon(
                //         //           property.isMinted ? Icons.more_horiz : Icons.shopping_bag,
                //         //           size: 16,
                //         //         ),
                //         //         const SizedBox(width: 8),
                //         //         Text(
                //         //           property.isMinted ? 'Details' : 'Buy Now',
                //         //           style: const TextStyle(
                //         //             fontSize: 12,
                //         //             fontWeight: FontWeight.w700,
                //         //           ),
                //         //         ),
                //         //       ],
                //         //     ),
                //         //   ),
                //         // ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
