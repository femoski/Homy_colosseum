import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:homy/models/nft_property_model.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/common/ui.dart';

class BuyConfirmationModal extends StatefulWidget {
  final NFTPropertyModel property;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const BuyConfirmationModal({
    Key? key,
    required this.property,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  State<BuyConfirmationModal> createState() => _BuyConfirmationModalState();
}

class _BuyConfirmationModalState extends State<BuyConfirmationModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isProcessing = false;
  String _processingMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Get.theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _isProcessing 
                      ? _buildProcessingView()
                      : _buildConfirmationView(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConfirmationView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Get.theme.colorScheme.primary.withOpacity(0.1),
                Get.theme.colorScheme.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: Get.theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Purchase',
                      style: MyTextStyle.productBold(
                        size: 18,
                        color: Get.theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review your property purchase',
                      style: MyTextStyle.productRegular(
                        size: 14,
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Property details
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Property image
              Container(
                height: 120,
                width: double.infinity,
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
                        size: 40,
                        color: Get.theme.colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Property info
              _buildPropertyInfo(),
              
              const SizedBox(height: 20),
              
              // Purchase details
              _buildPurchaseDetails(),
              
              const SizedBox(height: 20),
              
              // Warning message
              _buildWarningMessage(),
            ],
          ),
        ),
        
        // Action buttons
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel ?? () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _handleConfirmPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Get.theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Confirm Purchase'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyInfo() {
    return Column(
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
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${widget.property.metadata?['city'] ?? ''}, ${widget.property.metadata?['state'] ?? ''} ${widget.property.metadata?['zip'] ?? ''}',
                style: MyTextStyle.productRegular(
                  size: 14,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPurchaseDetails() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Property Price',
                style: MyTextStyle.productRegular(
                  size: 14,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                widget.property.metadata?['price'] ?? '0',
                style: MyTextStyle.productBold(
                  size: 16,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction Fee',
                style: MyTextStyle.productRegular(
                  size: 14,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                '₹50',
                style: MyTextStyle.productRegular(
                  size: 14,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: MyTextStyle.productBold(
                  size: 16,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              Text(
                widget.property.metadata?['price'] ?? '0', // In real app, add fees
                style: MyTextStyle.productBold(
                  size: 18,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Notice',
                  style: MyTextStyle.gilroySemiBold(
                    size: 14,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You\'re about to purchase this property. Once payment is confirmed, your NFT will be minted directly to your wallet.',
                  style: MyTextStyle.productRegular(
                    size: 13,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Processing animation
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Processing message
          Text(
            _processingMessage.isEmpty ? 'Processing payment...' : _processingMessage,
            style: MyTextStyle.productMedium(
              size: 16,
              color: Get.theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Please wait while we process your transaction',
            style: MyTextStyle.productRegular(
              size: 14,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleConfirmPurchase() async {
    setState(() {
      _isProcessing = true;
      _processingMessage = 'Processing payment...';
    });

    try {
      // Check wallet connection
      final walletService = SolanaWalletService.to;
      if (!walletService.isConnected.value) {
        setState(() {
          _isProcessing = false;
        });
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Please connect your wallet first',
        ));
        return;
      }

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _processingMessage = 'Payment confirmed!';
      });
      
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _processingMessage = 'Minting your NFT...';
      });

      // Call the onConfirm callback
      if (widget.onConfirm != null) {
        widget.onConfirm!();
      }

      // Close the modal
      Get.back();
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _processingMessage = '';
      });
      
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Purchase failed: ${e.toString()}',
      ));
    }
  }
}
