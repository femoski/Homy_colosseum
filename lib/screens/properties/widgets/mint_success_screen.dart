import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:homy/models/nft_property_model.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/common/ui.dart';

class MintSuccessScreen extends StatefulWidget {
  final NFTPropertyModel property;
  final String mintAddress;
  final String transactionSignature;
  final VoidCallback? onViewInWallet;
  final VoidCallback? onViewOnExplorer;
  final VoidCallback? onContinue;

  const MintSuccessScreen({
    Key? key,
    required this.property,
    required this.mintAddress,
    required this.transactionSignature,
    this.onViewInWallet,
    this.onViewOnExplorer,
    this.onContinue,
  }) : super(key: key);

  @override
  State<MintSuccessScreen> createState() => _MintSuccessScreenState();
}

class _MintSuccessScreenState extends State<MintSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _successController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSuccessAnimation();
  }

  @override
  void dispose() {
    _successController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Success checkmark animation
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    // Fade animation for content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Slide animation for content
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startSuccessAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _successController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Success animation
              Expanded(
                flex: 2,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Content
              Expanded(
                flex: 3,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            // Success message
                            Text(
                              'Your Property NFT has been minted!',
                              style: MyTextStyle.productBold(
                                size: 24,
                                color: Get.theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Text(
                              'Congratulations! Your property is now a verified NFT on the Solana blockchain.',
                              style: MyTextStyle.productRegular(
                                size: 16,
                                color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Property card
                            _buildPropertyCard(),
                            
                            const SizedBox(height: 24),
                            
                            // NFT details
                            _buildNFTDetails(),
                            
                            const Spacer(),
                            
                            // Action buttons
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Property image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Get.theme.colorScheme.surface,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: widget.property.nftImage ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Get.theme.colorScheme.surface,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
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
          ),
          
          const SizedBox(width: 16),
          
          // Property info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.nftName ?? 'Untitled Property',
                  style: MyTextStyle.productBold(
                    size: 16,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  widget.property.metadata?['price'] ?? '0',
                  style: MyTextStyle.gilroySemiBold(
                    size: 18,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${widget.property.metadata?['city'] ?? ''}, ${widget.property.metadata?['state'] ?? ''} ${widget.property.metadata?['zip'] ?? ''}',
                        style: MyTextStyle.productRegular(
                          size: 12,
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNFTDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Mint Address',
            _getShortAddress(widget.mintAddress),
            Icons.key,
            onTap: () => _copyToClipboard(widget.mintAddress),
          ),
          
          const SizedBox(height: 12),
          
          _buildDetailRow(
            'Transaction ID',
            _getShortAddress(widget.transactionSignature),
            Icons.receipt,
            onTap: () => _copyToClipboard(widget.transactionSignature),
          ),
          
          const SizedBox(height: 12),
          
          _buildDetailRow(
            'Network',
            'Solana Devnet',
            Icons.network_check,
          ),
          
          const SizedBox(height: 12),
          
          _buildDetailRow(
            'Status',
            'Confirmed',
            Icons.check_circle,
            valueColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
    Color? valueColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: MyTextStyle.productRegular(
                      size: 12,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: MyTextStyle.gilroySemiBold(
                      size: 14,
                      color: valueColor ?? Get.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            
            if (onTap != null)
              Icon(
                Icons.copy,
                size: 16,
                color: Get.theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onViewOnExplorer ?? _viewOnExplorer,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('View on Explorer'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onViewInWallet ?? _viewInWallet,
                icon: const Icon(Icons.account_balance_wallet, size: 18),
                label: const Text('View in Wallet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Continue button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onContinue ?? _continue,
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.surface,
              foregroundColor: Get.theme.colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Continue to Marketplace'),
          ),
        ),
      ],
    );
  }

  String _getShortAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 8)}';
  }

  void _copyToClipboard(String text) {
    // In a real app, you would use clipboard functionality
    Get.showSnackbar(CommonUI.SuccessSnackBar(
      message: 'Copied to clipboard',
    ));
  }

  void _viewOnExplorer() {
    // In a real app, you would open the Solana Explorer URL
    Get.showSnackbar(CommonUI.SuccessSnackBar(
      message: 'Opening Solana Explorer...',
    ));
  }

  void _viewInWallet() {
    // In a real app, you would open the Phantom Wallet deep link
    Get.showSnackbar(CommonUI.SuccessSnackBar(
      message: 'Opening Phantom Wallet...',
    ));
  }

  void _continue() {
    Get.back();
  }
}
