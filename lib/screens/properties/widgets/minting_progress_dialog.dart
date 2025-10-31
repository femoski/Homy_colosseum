import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/nft_property_model.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/common/ui.dart';

class MintingProgressDialog extends StatefulWidget {
  final NFTPropertyModel property;
  final VoidCallback? onComplete;
  final VoidCallback? onError;

  const MintingProgressDialog({
    Key? key,
    required this.property,
    this.onComplete,
    this.onError,
  }) : super(key: key);

  @override
  State<MintingProgressDialog> createState() => _MintingProgressDialogState();
}

class _MintingProgressDialogState extends State<MintingProgressDialog>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  
  int _currentStep = 0;
  String _currentMessage = 'Initializing minting process...';
  bool _isComplete = false;
  bool _hasError = false;
  String? _errorMessage;
  String? _mintAddress;
  String? _transactionSignature;

  final List<MintingStep> _steps = [
    MintingStep(
      title: 'Preparing NFT metadata',
      message: 'Creating unique property metadata...',
      icon: Icons.description,
    ),
    MintingStep(
      title: 'Uploading to IPFS',
      message: 'Storing property data on decentralized storage...',
      icon: Icons.cloud_upload,
    ),
    MintingStep(
      title: 'Creating mint account',
      message: 'Setting up Solana mint account...',
      icon: Icons.account_balance_wallet,
    ),
    MintingStep(
      title: 'Minting NFT',
      message: 'Minting your property NFT on Solana...',
      icon: Icons.diamond,
    ),
    MintingStep(
      title: 'Finalizing',
      message: 'Completing minting process...',
      icon: Icons.check_circle,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startMintingProcess();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Pulse animation for the main icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for loading indicator
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  void _startMintingProcess() async {
    for (int i = 0; i < _steps.length; i++) {
      if (mounted) {
        setState(() {
          _currentStep = i;
          _currentMessage = _steps[i].message;
        });
        
        // Animate progress
        _progressController.forward();
        
        // Simulate step processing time
        await Future.delayed(Duration(milliseconds: 1500 + (i * 500)));
        
        // Reset progress for next step
        _progressController.reset();
      }
    }

    // Complete the process
    if (mounted) {
      setState(() {
        _isComplete = true;
        _currentMessage = 'NFT minted successfully!';
        _mintAddress = 'GeneratedMintAddress${DateTime.now().millisecondsSinceEpoch}';
        _transactionSignature = 'GeneratedTxSig${DateTime.now().millisecondsSinceEpoch}';
      });
      
      // Stop animations
      _pulseController.stop();
      _rotationController.stop();
      
      // Call completion callback
      if (widget.onComplete != null) {
        await Future.delayed(const Duration(seconds: 1));
        widget.onComplete!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: 24),
              
              // Main animation
              _buildMainAnimation(),
              
              const SizedBox(height: 24),
              
              // Progress indicator
              _buildProgressIndicator(),
              
              const SizedBox(height: 24),
              
              // Current step info
              _buildCurrentStepInfo(),
              
              const SizedBox(height: 16),
              
              // Action buttons
              if (_isComplete || _hasError) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.diamond,
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
                _isComplete ? 'Minting Complete!' : 'Minting your NFT',
                style: MyTextStyle.productBold(
                  size: 18,
                  color: Get.theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.property.nftName ?? 'Property NFT',
                style: MyTextStyle.productRegular(
                  size: 14,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainAnimation() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Get.theme.colorScheme.primary.withOpacity(0.1),
                Get.theme.colorScheme.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
            child: Transform.scale(
              scale: _isComplete ? 1.0 : _pulseAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isComplete 
                      ? Colors.green
                      : Get.theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isComplete 
                          ? Colors.green
                          : Get.theme.colorScheme.primary).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isComplete ? Icons.check : Icons.diamond,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        // Progress bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(2),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _isComplete ? 1.0 : (_currentStep + _progressAnimation.value) / _steps.length,
                child: Container(
                  decoration: BoxDecoration(
                    color: _isComplete 
                        ? Colors.green
                        : Get.theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Step counter
        Text(
          'Step ${_currentStep + 1} of ${_steps.length}',
          style: MyTextStyle.productRegular(
            size: 12,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _isComplete 
                    ? Icons.check_circle
                    : _steps[_currentStep].icon,
                color: _isComplete 
                    ? Colors.green
                    : Get.theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isComplete 
                      ? 'Minting Complete!'
                      : _steps[_currentStep].title,
                  style: MyTextStyle.gilroySemiBold(
                    size: 14,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _currentMessage,
            style: MyTextStyle.productRegular(
              size: 13,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (_isComplete) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _viewOnExplorer(),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('View on Explorer'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _viewInWallet(),
              icon: const Icon(Icons.account_balance_wallet, size: 16),
              label: const Text('View in Wallet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ] else if (_hasError) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ],
    );
  }

  void _viewOnExplorer() {
    if (_mintAddress != null) {
      // In a real app, you would open the Solana Explorer URL
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: 'Opening Solana Explorer...',
      ));
    }
  }

  void _viewInWallet() {
    if (_mintAddress != null) {
      // In a real app, you would open the Phantom Wallet deep link
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: 'Opening Phantom Wallet...',
      ));
    }
  }
}

class MintingStep {
  final String title;
  final String message;
  final IconData icon;

  const MintingStep({
    required this.title,
    required this.message,
    required this.icon,
  });
}
