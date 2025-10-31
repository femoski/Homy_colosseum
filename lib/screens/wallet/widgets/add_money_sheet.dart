import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/screens/wallet/controllers/wallet_controller.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:homy/services/config_service.dart';

enum PaymentMethod { creditCard, bank, solanaWallet }

class AddMoneySheet extends GetWidget<WalletController> {
  AddMoneySheet({Key? key}) : super(key: key);
  final ConfigService? configService = Get.find<ConfigService>();
  final Rx<PaymentMethod> selectedPaymentMethod = PaymentMethod.creditCard.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildAmountInput(),
          const SizedBox(height: 24),
          _buildPaymentMethods(),
          const SizedBox(height: 24),
          _buildAddMoneyButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Money',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add money to your wallet',
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter amount',
            prefixText: controller.currencySymbol + ' ', 
            prefixStyle: Get.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
            // prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Get.theme.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (configService?.config.value?.payments.getEnableCreditCardPayments ?? false) ...[
              Expanded(
                child: Obx(() => _buildPaymentMethodCard(
                  icon: Icons.credit_card,
                  title: 'Credit Card',
                  isSelected: selectedPaymentMethod.value == PaymentMethod.creditCard,
                  onTap: () => selectedPaymentMethod.value = PaymentMethod.creditCard,
                )),
              ),
            ],
        
              if (configService?.config.value?.payments.getEnableSolanaPayments ?? false) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _buildPaymentMethodCard(
                  icon: Icons.account_balance_wallet,
                  title: 'Solana Wallet',
                  isSelected: selectedPaymentMethod.value == PaymentMethod.solanaWallet,
                  onTap: () => selectedPaymentMethod.value = PaymentMethod.solanaWallet,
                  isFullWidth: true,
                )),
              ),
            ],
            
            // Expanded(
            //   child: Obx(() => _buildPaymentMethodCard(
            //     icon: Icons.account_balance,
            //     title: 'Bank',
            //     isSelected: selectedPaymentMethod.value == PaymentMethod.bank,
            //     onTap: () => selectedPaymentMethod.value = PaymentMethod.bank,
            //   )),
            // ),

          ],
        ),
        // const SizedBox(height: 12),
        // Obx(() => _buildPaymentMethodCard(
        //   icon: Icons.account_balance_wallet,
        //   title: 'Solana Wallet',
        //   isSelected: selectedPaymentMethod.value == PaymentMethod.solanaWallet,
        //   onTap: () => selectedPaymentMethod.value = PaymentMethod.solanaWallet,
        //   isFullWidth: true,
        // )),
        Obx(() => _buildSolanaWalletStatus()),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    Widget card = Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isSelected ? Get.theme.primaryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Get.theme.primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Get.theme.primaryColor : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Get.theme.primaryColor : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (isFullWidth) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    } else {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: card,
        ),
      );
    }
  }

  Widget _buildSolanaWalletStatus() {
    if (selectedPaymentMethod.value != PaymentMethod.solanaWallet) {
      return const SizedBox.shrink();
    }

    final solanaService = Get.find<SolanaWalletService>();
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: solanaService.isConnected.value 
            ? Colors.green.withOpacity(0.1) 
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: solanaService.isConnected.value 
              ? Colors.green 
              : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            solanaService.isConnected.value 
                ? Icons.check_circle 
                : Icons.warning,
            color: solanaService.isConnected.value 
                ? Colors.green 
                : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  solanaService.isConnected.value 
                      ? 'Wallet Connected' 
                      : 'Wallet Not Connected',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: solanaService.isConnected.value 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                ),
                if (solanaService.isConnected.value) ...[
                  Text(
                    '${solanaService.getShortAddress()} • ${solanaService.getFormattedBalance()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ] else ...[
                  Text(
                    'Connect your Solana wallet to add money',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!solanaService.isConnected.value)
            TextButton(
              onPressed: () async {
                await solanaService.connectWallet();
              },
              child: const Text('Connect'),
            ),
        ],
      ),
    );
  }

  Widget _buildAddMoneyButton() {
    return Obx(() {
      final solanaService = Get.find<SolanaWalletService>();
      final isSolanaSelected = selectedPaymentMethod.value == PaymentMethod.solanaWallet;
      final isSolanaConnected = solanaService.isConnected.value;
      
      return ElevatedButton(
        onPressed: () async {
          final amount = double.tryParse(controller.amountController.text);
          if (amount == null || amount <= 0) {
            Get.showSnackbar(CommonUI.ErrorSnackBar(
              message: 'Please enter a valid amount',
            ));
            return;
          }
          
          if (isSolanaSelected && !isSolanaConnected) {
            Get.showSnackbar(CommonUI.ErrorSnackBar(
              message: 'Please connect your Solana wallet first',
            ));
            return;
          }
          
          Get.back();
          
          if (isSolanaSelected) {
            await controller.addMoneyViaSolana(amount);
          } else {
            await controller.addMoney(amount);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isSolanaSelected && !isSolanaConnected 
              ? 'Connect Wallet First' 
              : 'Add Money',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }
} 