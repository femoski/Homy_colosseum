import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/common/ui.dart';

class WalletConnectionWidget extends StatelessWidget {
  final VoidCallback? onConnectPressed;
  final bool showConnectButton;

  const WalletConnectionWidget({
    Key? key,
    this.onConnectPressed,
    this.showConnectButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final walletService = SolanaWalletService.to;
    
    return Obx(() {
      if (walletService.isConnected.value) {
        return _buildConnectedState(walletService);
      } else {
        return _buildDisconnectedState();
      }
    });
  }

  Widget _buildConnectedState(SolanaWalletService walletService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Connected',
                      style: MyTextStyle.gilroySemiBold(
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      walletService.walletName.value,
                      style: MyTextStyle.productRegular(
                        size: 14,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showWalletDetails(walletService),
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Wallet address
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.key,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    walletService.getShortAddress(),
                    style: MyTextStyle.productRegular(
                      size: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _copyAddress(walletService.getFullAddress()),
                  icon: const Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Balance
          Row(
            children: [
              Icon(
                Icons.account_balance,
                size: 16,
                color: Colors.green.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Balance: ${walletService.getFormattedBalance()}',
                style: MyTextStyle.gilroySemiBold(
                  size: 14,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectedState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Not Connected',
                      style: MyTextStyle.gilroySemiBold(
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Connect your Solana wallet to buy properties',
                      style: MyTextStyle.productRegular(
                        size: 14,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (showConnectButton) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onConnectPressed ?? _connectWallet,
                icon: const Icon(Icons.link, size: 18),
                label: const Text('Connect Wallet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _connectWallet() async {
    try {
      await SolanaWalletService.to.connectWallet();
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to connect wallet: ${e.toString()}',
      ));
    }
  }

  void _showWalletDetails(SolanaWalletService walletService) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Wallet Details',
            style: MyTextStyle.productBold(size: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Wallet Name', walletService.walletName.value),
            _buildDetailRow('Address', walletService.getFullAddress()),
            _buildDetailRow('Balance', walletService.getFormattedBalance()),
            _buildDetailRow('Status', 'Connected'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _disconnectWallet();
            },
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: MyTextStyle.gilroySemiBold(size: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: MyTextStyle.productRegular(size: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _copyAddress(String address) {
    // In a real app, you would use clipboard functionality
    Get.showSnackbar(CommonUI.SuccessSnackBar(
      message: 'Address copied to clipboard',
    ));
  }

  void _disconnectWallet() async {
    try {
      await SolanaWalletService.to.disconnectWallet();
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to disconnect wallet: ${e.toString()}',
      ));
    }
  }
}

/// Compact wallet status indicator for app bars
class WalletStatusIndicator extends StatelessWidget {
  final VoidCallback? onTap;

  const WalletStatusIndicator({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final walletService = SolanaWalletService.to;
    
    return Obx(() {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: walletService.isConnected.value 
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: walletService.isConnected.value 
                  ? Colors.green.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                walletService.isConnected.value 
                    ? Icons.account_balance_wallet
                    : Icons.account_balance_wallet_outlined,
                size: 16,
                color: walletService.isConnected.value 
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(width: 6),
              Text(
                walletService.isConnected.value 
                    ? 'Connected'
                    : 'Connect',
                style: MyTextStyle.gilroySemiBold(
                  size: 12,
                  color: walletService.isConnected.value 
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
