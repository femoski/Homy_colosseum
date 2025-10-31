import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/wallet/controllers/wallet_controller.dart';
import 'package:homy/services/solana_wallet_service.dart';

import '../../../common/ui.dart';

class WithdrawMoneySheet extends StatelessWidget {
  const WithdrawMoneySheet({Key? key}) : super(key: key);

  void _showConfirmationDialog(BuildContext context, WalletController controller) {
    final amount = double.tryParse(controller.amountController.text) ?? 0.0;
    final fee = controller.withdrawalFee;
    final totalAmount = amount + fee;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confirm Withdrawal',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildInfoRow(
                context,
                'Bank',
                controller.getSelectedBankName(),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                'Account Number',
                controller.accountNumberController.text,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                'Account Name',
                controller.accountHolderName ?? '',
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              _buildAmountRow(
                context,
                'Amount',
                '₦${amount.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 12),
              _buildAmountRow(
                context,
                'Fee',
                '₦${fee.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 12),
              _buildAmountRow(
                context,
                'Total',
                '₦${totalAmount.toStringAsFixed(2)}',
                isTotal: true,
              ),
       

              if (controller.requirePinForWithdrawal) ...[
                const SizedBox(height: 32),
              Text(
                'Enter Transaction PIN',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.transactionPinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter 4-digit PIN',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  counterText: '',
                ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (controller.requirePinForWithdrawal) {
                          if (controller.transactionPinController.text.length != 4) {
                            Get.showSnackbar(CommonUI.ErrorSnackBar(
                              message: 'Please enter a valid 4-digit PIN',
                          ));
                          return;
                        }

                        final isPinValid = await controller.verifyTransactionPin(
                          controller.transactionPinController.text,
                        );

                        if (isPinValid) {
                          Get.back();
                          controller.processWithdrawal(
                            amount,
                            controller.selectedBankCode!,
                            controller.accountNumberController.text,
                          );
                        }
                      }
                      else {
                        Get.back();
                        controller.processWithdrawal(
                          amount,
                          controller.selectedBankCode!,
                          controller.accountNumberController.text,
                        );
                      }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isVerifyingPin
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFamily: 'Roboto ',
            color: isTotal ? Theme.of(context).colorScheme.primary : null,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFamily: 'Roboto',
            color: isTotal ? Theme.of(context).colorScheme.primary : null,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          // padding: EdgeInsets.only(
          //   bottom: MediaQuery.of(context).viewInsets.bottom,
          // ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Withdraw Money',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  
                  // Withdrawal Type Selection
                  if ((controller.configService?.config.value?.payments.getEnableBankWithdrawals ?? false) || (controller.configService?.config.value?.payments.getEnableSolanaPayments ?? false)) ...[
                  Text(
                    'Withdrawal Method',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Row(
                    children: [
                      if (controller.configService?.config.value?.payments.getEnableBankWithdrawals ?? false) ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.setWithdrawalType('bank'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: controller.withdrawalType.value == 'bank' 
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: controller.withdrawalType.value == 'bank'
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance,
                                  color: controller.withdrawalType.value == 'bank'
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Bank Transfer',
                                  style: TextStyle(
                                    color: controller.withdrawalType.value == 'bank'
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                    fontWeight: controller.withdrawalType.value == 'bank'
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ],
                      if (controller.configService?.config.value?.payments.getEnableSolanaPayments ?? false) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => controller.setWithdrawalType('solana'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: controller.withdrawalType.value == 'solana' 
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: controller.withdrawalType.value == 'solana'
                                    ? Colors.orange
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: controller.withdrawalType.value == 'solana'
                                      ? Colors.orange
                                      : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Solana Wallet',
                                  style: TextStyle(
                                    color: controller.withdrawalType.value == 'solana'
                                        ? Colors.orange
                                        : Colors.grey,
                                    fontWeight: controller.withdrawalType.value == 'solana'
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ],
                    ],
                  )),
                    const SizedBox(height: 24),
                  ],
                  // Conditional content based on withdrawal type
                  Obx(() {
                    if (controller.withdrawalType.value == 'bank' && (controller.configService?.config.value?.payments.getEnableBankWithdrawals ?? false)) {
                      return _buildBankWithdrawalForm(context, controller);
                    } else {
                      return _buildSolanaWithdrawalForm(context, controller);
                    }
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBankWithdrawalForm(BuildContext context, WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: controller.selectedBankCode,
          decoration: InputDecoration(
            labelText: 'Select Bank',
            prefixIcon: const Icon(Icons.account_balance),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          items: controller.banks.map((bank) {
            return DropdownMenuItem(
              value: bank.code,
              child: Text(
                bank.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: controller.onBankSelected,
          isExpanded: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.accountNumberController,
          keyboardType: TextInputType.number,
          maxLength: 10,
          onChanged: (value) {
            if (value.length == 10) {
              controller.verifyAccount(value);
            }
          },
          decoration: InputDecoration(
            labelText: 'Account Number',
            prefixIcon: const Icon(Icons.account_balance_wallet),
            suffixIcon: controller.isVerifyingAccount
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (controller.accountHolderName != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.accountHolderName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Enter Amount',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₦  ',
            prefixStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Show fee breakdown for bank withdrawal
        // Obx(() {
        //   if (controller.withdrawalAmount.value > 0) {
        //     final fee = controller.withdrawalFee;
        //     final totalAmount = controller.withdrawalAmount.value + fee;
            
        //     return Container(
        //       padding: const EdgeInsets.all(12),
        //       decoration: BoxDecoration(
        //         color: Get.theme.colorScheme.primary.withOpacity(0.1),
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Row(
        //             children: [
        //               Icon(Icons.info_outline, color: Get.theme.colorScheme.primary, size: 20),
        //               const SizedBox(width: 8),
        //               Expanded(
        //                 child: Text(
        //                   'Withdrawal Breakdown',
        //                   style: TextStyle(
        //                     color: Get.theme.colorScheme.primary,
        //                     fontSize: 14,
        //                     fontWeight: FontWeight.w600,
        //                   ),
        //                 ),
        //               ),
        //             ],
        //           ),
        //           const SizedBox(height: 12),
        //           _buildBankAmountRow(
        //             'Amount',
        //             '₦${controller.withdrawalAmount.value.toStringAsFixed(2)}',
        //           ),
        //           const SizedBox(height: 8),
        //           _buildBankAmountRow(
        //             'Fee',
        //             '₦${fee.toStringAsFixed(2)}',
        //           ),
        //           const SizedBox(height: 8),
        //           _buildBankAmountRow(
        //             'Total',
        //             '₦${totalAmount.toStringAsFixed(2)}',
        //             isTotal: true,
        //           ),
        //         ],
        //       ),
        //     );
        //   }
        //   return const SizedBox.shrink();
        // }),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading
                ? null
                : () {
                    if (controller.selectedBankCode == null) {
                      Get.showSnackbar(CommonUI.ErrorSnackBar(
                        message: 'Please select bank',
                      ));
                      return;
                    }
                    if (controller.accountNumberController.text.isEmpty) {
                      Get.showSnackbar(CommonUI.ErrorSnackBar(
                        message: 'Please enter account number',
                      ));
                      return;
                    }

                    if (controller.accountHolderName == null) {
                      Get.showSnackbar(CommonUI.ErrorSnackBar(
                        message: 'Account Name not Verified',
                      ));
                      return;
                    }
                    final amount = double.tryParse(
                          controller.amountController.text,
                        ) ??
                        0.0;
                    final fee = controller.withdrawalFee;
                    final totalAmount = amount + fee;
                    
                    if (amount < controller.minimumWithdrawalAmount) {
                      Get.showSnackbar(GetSnackBar(
                        message: 'Minimum withdrawal amount is ₦${controller.minimumWithdrawalAmount.toStringAsFixed(2)}',
                        duration: const Duration(seconds: 2),
                      ));
                      return;
                    }
                    if (totalAmount > controller.walletBalance) {
                      Get.showSnackbar(CommonUI.ErrorSnackBar(
                        message: 'Insufficient balance. Total amount including fee is ₦${totalAmount.toStringAsFixed(2)}',
                      ));
                      return;
                    }
                    _showConfirmationDialog(context, controller);
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: controller.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Withdraw'),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Note: Minimum withdrawal amount is ₦${controller.minimumWithdrawalAmount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontFamily: 'Roboto',
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSolanaWithdrawalForm(BuildContext context, WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Solana Wallet Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                ),
              ),
            ),
            Obx(() {
              final isConnected = Get.find<SolanaWalletService>().isConnected.value;
              final connectedAddress = Get.find<SolanaWalletService>().getFullAddress();
              if (isConnected && connectedAddress.isNotEmpty && controller.solanaAddressController.text.isEmpty) {
                return IconButton(
                  icon: const Icon(Icons.link),
                  tooltip: 'Use connected wallet address',
                  onPressed: () {
                    controller.solanaAddressController.text = connectedAddress;
                    controller.validateSolanaAddress(controller.solanaAddressController.text);
                  },
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear address field',
                  onPressed: () {
                    controller.solanaAddressController.clear();
                    controller.validateSolanaAddress(controller.solanaAddressController.text);
                  },
                );
              }
            }),
          ],
        ),
        // Text(
        //   'Solana Wallet Details',
        //   style: Theme.of(context).textTheme.titleMedium,
        // ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.solanaAddressController,
          onChanged: (value) => controller.validateSolanaAddress(value),
          decoration: InputDecoration(
            labelText: 'Recipient Solana Address',
            prefixIcon:  Icon(Icons.account_balance_wallet, color: Get.theme.colorScheme.primary),
            hintText: 'Enter Solana wallet address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: Obx(() {
              if (controller.isSolanaAddressValid.value) {
                return const Icon(Icons.check_circle, color: Colors.green);
              } else if (controller.solanaAddressController.text.isNotEmpty) {
                return const Icon(Icons.error, color: Colors.red);
              }
              return const SizedBox.shrink();
            }),
          ),
        ),
        if (controller.solanaAddressController.text.isNotEmpty && !controller.isSolanaAddressValid.value) ...[
          const SizedBox(height: 8),
          Text(
            'Please enter a valid Solana address (32-44 characters)',
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Enter Amount',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '₦  ',
            prefixStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Show SOL conversion preview and fee breakdown
        Obx(() {
          if (controller.withdrawalAmount.value > 0) {
            final fee = controller.withdrawalFee;
            final totalAmount = controller.withdrawalAmount.value + fee;
            final solAmount = controller.withdrawalAmount.value / 150000;
            final feeInSol = fee / 150000;
            final totalSolAmount = totalAmount / 150000;
            
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Get.theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Withdrawal Breakdown',
                          style: TextStyle(
                            color: Get.theme.colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSolanaAmountRow(
                    'Amount',
                    '₦${controller.withdrawalAmount.value.toStringAsFixed(2)}',
                    '${solAmount.toStringAsFixed(4)} SOL',
                  ),
                  const SizedBox(height: 8),
                  _buildSolanaAmountRow(
                    'Fee',
                    '₦${fee.toStringAsFixed(2)}',
                    '${feeInSol.toStringAsFixed(4)} SOL',
                  ),
                  const SizedBox(height: 8),
                  _buildSolanaAmountRow(
                    'Total',
                    '₦${totalAmount.toStringAsFixed(2)}',
                    '${totalSolAmount.toStringAsFixed(4)} SOL',
                    isTotal: true,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.isLoading
                ? null
                : () {
                    if (!controller.isSolanaAddressValid.value) {
                      Get.showSnackbar(CommonUI.ErrorSnackBar(
                        message: 'Please enter a valid Solana address',
                      ));
                      return;
                    }
                    final amount = double.tryParse(
                          controller.amountController.text,
                        ) ??
                        0.0;
                    final fee = controller.withdrawalFee;
                    final totalAmount = amount + fee;
                    
                    if (amount < controller.minimumWithdrawalAmount) {
                      Get.showSnackbar(CommonUI.ErrorSnackBar(
                        message: 'Minimum withdrawal amount is ₦${controller.minimumWithdrawalAmount.toStringAsFixed(2)}',
                      ));
                      return;
                    }
                    if (totalAmount > controller.walletBalance) {
                      Get.showSnackbar(CommonUI.ErrorSnackBar(
                        message: 'Insufficient balance. Total amount including fee is ₦${totalAmount.toStringAsFixed(2)}',
                      ));
                      return;
                    }
                    controller.processSolanaWithdrawal(
                      amount,
                      controller.solanaAddressController.text.trim(),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: controller.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Withdraw to Solana',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Note: Minimum withdrawal amount is ₦${controller.minimumWithdrawalAmount.toStringAsFixed(2)}. SOL will be sent to the provided address.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontFamily: 'Roboto',
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSolanaAmountRow(String label, String ngnValue, String solValue, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? Get.theme.colorScheme.primary : null,
          ),
        ),
        Row(
          children: [
            Text(
              ngnValue,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                color: isTotal ? Get.theme.colorScheme.primary : null,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(width: 8),
            Text(
              solValue,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                color: isTotal ? Get.theme.colorScheme.primary : Colors.grey[600],
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBankAmountRow(String label, String ngnValue, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? Get.theme.colorScheme.primary : null,
          ),
        ),
        Text(
          ngnValue,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? Get.theme.colorScheme.primary : null,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }
} 