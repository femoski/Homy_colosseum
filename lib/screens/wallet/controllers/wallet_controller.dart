import 'package:get/get.dart';
import 'package:homy/models/wallet/transaction.dart';
import 'package:homy/repositories/wallet_repository.dart';
import 'package:homy/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:homy/screens/payment/payment_webview_screen.dart';
import 'package:homy/screens/wallet/widgets/add_money_sheet.dart';
import 'package:homy/screens/wallet/widgets/withdraw_money_sheet.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/services/config_service.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:homy/services/solana_exchange_service.dart';

class WalletController extends GetxController {
  final WalletRepository _walletRepository = WalletRepository();


  final authService = Get.find<AuthService>();
  Rx<UserData>? user;
  ConfigService? configService;

  double get minimumWithdrawalAmount => configService?.config.value?.payments.getMinimumWithdrawalAmount ?? 100;
  double get maximumWithdrawalAmount => configService?.config.value?.payments.getMaximumWithdrawalAmount ?? 1000000;
  double get withdrawalFee => configService?.config.value?.payments.getWithdrawalFee ?? 50;
  bool get requirePinForWithdrawal => configService?.config.value?.payments.getRequirePinForWithdrawal ?? false;
  String get currencySymbol => configService?.config.value?.payments.getCurrencySymbol ?? '₦';

  double walletBalance = 0.0;
  List<Transaction> transactions = [];
  bool isLoading = false;
  bool isAgent = true;
  bool isWalletFrozen = true; // Add frozen status property
  final TextEditingController amountController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController transactionPinController = TextEditingController();

  // Add these new properties
  List<Bank> banks = [];
  String? selectedBankCode;
  String? accountHolderName;
  bool isVerifyingAccount = false;
  bool isVerifyingPin = false;

  final Rx<Bank?> selectedBank = Rx<Bank?>(null);
  final RxBool isAccountVerified = false.obs;
  final RxString verifiedAccountName = ''.obs;

  // Solana withdrawal properties
  final RxString withdrawalType = 'bank'.obs; // 'bank' or 'solana'
  final TextEditingController solanaAddressController = TextEditingController();
  final RxBool isSolanaAddressValid = false.obs;
  final RxDouble withdrawalAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    user = authService.user;
    if (user?.value.role == 'agent') {
      isAgent = true;
    } else {
      isAgent = false;
    }
    fetchWalletData();
    fetchBanks();
    amountController.addListener(() {
      updateWithdrawalAmount();
    });
    fetchConfig();
  }

  Future<void> fetchConfig() async {
    configService = await ConfigService.getConfig();
  }
  @override
  void dispose() {
    amountController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    transactionPinController.dispose();
    solanaAddressController.dispose();
    super.dispose();
  }

  Future<void> refreshWallet() async {
    await fetchWalletData();
  }

  // Method to toggle frozen status for testing
  void toggleFrozenStatus() {
    isWalletFrozen = !isWalletFrozen;
    update();
  }

  Future<void> fetchWalletData() async {
    try {
      isLoading = true;
      update();

      // Fetch balance and transactions concurrently
      await Future.wait([
        fetchBalance(),
        fetchTransactions(),
      ]);
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to fetch wallet details',
      ));
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> fetchBalance() async {
    try {
      final balance = await _walletRepository.getWalletBalance();
      walletBalance = balance;
      update();
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to fetch wallet balance',
      ));
    }
  }

  Future<void> fetchTransactions() async {
    final fetchedTransactions = await _walletRepository.getTransactions();
    print(fetchedTransactions);
    try {
      transactions = fetchedTransactions.transactions;
      update();
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to fetch',
      ));
    }
  }

  void onAddMoneyTap() {
    Get.bottomSheet(
      AddMoneySheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void onWithdrawTap() {
    if (walletBalance < minimumWithdrawalAmount) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Minimum withdrawal amount is ₦${minimumWithdrawalAmount.toStringAsFixed(2)}',
      ));
      return;
    }

    Get.bottomSheet(
      const WithdrawMoneySheet(),
      isScrollControlled: true,
      // backgroundColor: Colors.transparent,
    );
  }

  void onAgentEarningsTap() {
    // TODO: Implement navigation to agent earnings screen

    Get.toNamed('/agent-earnings');
    // Get.snackbar(
    //   'Coming Soon',
    //   'Agent earnings feature will be available soon',
    //   snackPosition: SnackPosition.BOTTOM,
    // );
  }

  Future<bool> verifyTransactionPin(String pin) async {
    if (pin.length != 4) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Please enter a valid 4-digit PIN',
      ));
      return false;
    }

    try {
      isVerifyingPin = true;
      update();

      // TODO: Implement actual PIN verification with backend
      // For now, we'll just simulate a successful verification
      await Future.delayed(const Duration(seconds: 1));
      
      return true;
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Invalid transaction PIN',
      ));
      return false;
    } finally {
      isVerifyingPin = false;
      update();
    }
  }

  Future<void> processWithdrawal(double amount, String bankCode, String accountNumber) async {
    try {
      isLoading = true;
      update();

      final fee = withdrawalFee;
      final totalAmount = amount + fee;

      Map<String, dynamic> data = {
        'amount': amount,
        'fee': fee,
        'total_amount': totalAmount,
        'bank_code': bankCode,
        'account_number': accountNumber,
      };

      if (requirePinForWithdrawal) {
        if (transactionPinController.text.isEmpty) {
          Get.showSnackbar(CommonUI.ErrorSnackBar(
            message: 'Transaction PIN is required',
          ));
          return;
        }
        data['transaction_pin'] = transactionPinController.text;
      }

      await _walletRepository.withdrawMoney(data);

      Get.back(); // Close bottom sheet
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: 'Withdrawal request submitted successfully',
      ));

      await fetchWalletData(); // Refresh wallet data
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: e.toString().split('Exception: ').last,
      ));
    } finally {
      isLoading = false;
      update();
    }
  }



  Future<void> showSuccessDialog() async {
    await Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 72,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your money has been added successfully. Check your email for confirmation details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back(); // Return to previous screen
                      },
                      child: Text(
                        'View History',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.until((route) => route.isFirst); // Navigate to home
                      },
                      child: const Text(
                        'Go to Home',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> showFailureDialog() async {
    await Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 72,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Cancelled',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'The payment process was cancelled. Please try again to schedule your tour.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Get.theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Get.back(); // Close dialog
                  },
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }



  Future<void> addMoney(double amount) async {
    try {
      isLoading = true;
      update();
      final response = await _walletRepository.addMoney(amount);

      if (response['authorization_url'] != null) {

          final result = await Get.to<bool>(() => PaymentWebViewScreen(
                  authorizationUrl: response['authorization_url'],
                  onComplete: (success) {
                    Get.log('Payment completed with success: $success');
                  },
                ));
        Get.log('Payment result from navigation: $result');

         if (result == true) {
        await showSuccessDialog();
      } else {
        await showFailureDialog();
      }
        // return result ?? false;


        // final success = await Get.to<bool>(() => PaymentWebViewScreen(
        //           authorizationUrl: response['authorization_url'],
        //           onComplete: (success) async {
        //              Get.back();
        //             if (success) {
        //               Get.snackbar(
        //                 'Success',
        //                 'Your payment has been successful!',
        //                 backgroundColor: Colors.green,
        //                 colorText: Colors.white,
        //                 snackPosition: SnackPosition.BOTTOM,
        //               );
        //               Get.dialog(
        //                 Dialog(
        //                   shape: RoundedRectangleBorder(
        //                     borderRadius: BorderRadius.circular(20),
        //                   ),
        //                   child: Container(
        //                     padding: const EdgeInsets.all(24),
        //                     child: Column(
        //                       mainAxisSize: MainAxisSize.min,
        //                       children: [
        //                         Container(
        //                           padding: const EdgeInsets.all(16),
        //                           decoration: BoxDecoration(
        //                             color: Colors.green.shade50,
        //                             shape: BoxShape.circle,
        //                           ),
        //                           child: Icon(
        //                             Icons.check_circle,
        //                             color: Colors.green,
        //                             size: 72,
        //                           ),
        //                         ),
        //                         SizedBox(height: 24),
        //                         Text(
        //                           'Payment Successful!',
        //                           style: TextStyle(
        //                             fontSize: 24,
        //                             fontWeight: FontWeight.bold,
        //                           ),
        //                         ),
        //                         SizedBox(height: 16),
        //                         Text(
        //                           'Your payment has been successful. Check your email for confirmation details.',
        //                           textAlign: TextAlign.center,
        //                           style: TextStyle(
        //                             fontSize: 16,
        //                             color: Colors.grey[600],
        //                           ),
        //                         ),
        //                         SizedBox(height: 24),
        //                         Row(
        //                           mainAxisAlignment:
        //                               MainAxisAlignment.spaceEvenly,
        //                           children: [
        //                             TextButton(
        //                               onPressed: () {
        //                                 Get.back(); // Close dialog
        //                                 // Get.back(); // Return to previous screen
        //                               },
        //                               child: Text(
        //                                 'View History',
        //                                 style: TextStyle(
        //                                   color: Colors.grey[600],
        //                                 ),
        //                               ),
        //                             ),
        //                             ElevatedButton(
        //                               style: ElevatedButton.styleFrom(
        //                                 backgroundColor:
        //                                     Get.theme.colorScheme.primary,
        //                                 padding: EdgeInsets.symmetric(
        //                                   horizontal: 32,
        //                                   vertical: 12,
        //                                 ),
        //                                 shape: RoundedRectangleBorder(
        //                                   borderRadius:
        //                                       BorderRadius.circular(30),
        //                                 ),
        //                               ),
        //                               onPressed: () {
        //                                 Get.back(); // Close dialog
        //                                 Get.until((route) =>
        //                                     route.isFirst); // Navigate to home
        //                               },
        //                               child: Text(
        //                                 'Go to Home',
        //                                 style: TextStyle(
        //                                   fontSize: 16,
        //                                   color: Colors.white,
        //                                 ),
        //                               ),
        //                             ),
        //                           ],
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                 ),
        //                 barrierDismissible: false,
        //               );
        //             }
        //             else {
        //               Get.snackbar(
        //                 'Payment Cancelled',
        //                 'The payment process was cancelled.',
        //                 backgroundColor: Colors.orange,
        //                 colorText: Colors.white,
        //                 snackPosition: SnackPosition.BOTTOM,
        //               );
        //             }
        //           },
        //         )) ??
        //     false;
            
      } else if (response['status'] == 400) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(message: response['message']));
        throw Exception(response['message']);
        // throw response['message'];
      }

      await fetchWalletData();
      // Get.back();
      // Get.showSnackbar(CommonUI.SuccessSnackBar(
      //   message: 'Money added successfully',
      // ));
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to add money',
      ));
    }
  }

  Future<void> fetchBanks() async {
    try {

      final response = await _walletRepository.getBanks();
      banks = response;
      update();
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to fetch banks list',
      ));
    }
  }

  void onBankSelected(String? bankCode) {
    selectedBankCode = bankCode;
    accountHolderName = null;
    update();
  }

  Future<void> verifyAccount(String accountNumber) async {
    if (accountNumber.length != 10 || selectedBankCode == null) return;

    isVerifyingAccount = true;
    update();

    try {
        final response = await _walletRepository.verifyAccount(accountNumber, selectedBankCode!);
      accountHolderName = response['account_name'];
      update();
    } catch (e) {
      accountHolderName = null;
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to verify account',
      ));
    } finally {
      isVerifyingAccount = false;
      update();
    }
  }

  String getSelectedBankName() {
    if (selectedBankCode == null) return '';
    final bank = banks.firstWhere((b) => b.code == selectedBankCode, orElse: () => Bank(code: '', name: ''));
    return bank.name;
  }

  Future<void> addMoneyViaSolana(double amount) async {
    try {
      isLoading = true;
      update();

      final solanaService = Get.find<SolanaWalletService>();
      
      if (!solanaService.isConnected.value) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Please connect your Solana wallet first',
        ));
        return;
      }

           // Convert SOL to NGN using current exchange rate
      final exchangeService = Get.find<SolanaExchangeService>();
      final solAmount = exchangeService.convertNgnToSol(amount);
      Get.log('solAmount: $solAmount');

      // Check if user has sufficient balance
      if (solanaService.balance.value < solAmount) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Insufficient SOL balance. You have ${solanaService.getFormattedBalance()} SOL',
        ));
        return;
      }

      // Get app's Solana wallet address (this should be configured in your app settings)
      final appWalletAddress = await _getAppSolanaWalletAddress();
      
      if (appWalletAddress == null) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'App wallet address not configured',
        ));
        return;
      }

      // Show confirmation dialog
      final confirmed = await _showSolanaTransactionConfirmation(solAmount, appWalletAddress);
      if (!confirmed) return;

      // Create and send Solana transaction
      Get.showSnackbar(CommonUI.InfoSnackBar(
        message: 'Processing Solana transaction...',
      ));

      final transactionSignature = await solanaService.sendPayment(
        recipientAddress: appWalletAddress,
        solAmount: solAmount,
        memo: 'Homy App - Add Money - User: ${user?.value.id ?? 'unknown'}',
      );

      if (transactionSignature == null) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Transaction failed to send',
        ));
        return;
      }

      // Convert SOL to NGN using current exchange rate
      final ngnAmount = exchangeService.convertSolToNgn(solAmount);
      
      // Update user's wallet balance via API
      await _updateWalletBalanceViaApi(ngnAmount, transactionSignature, amount);

      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: 'Successfully added ₦${ngnAmount.toStringAsFixed(2)} via Solana wallet\nTransaction: ${transactionSignature.substring(0, 8)}...',
      ));

      await fetchWalletData();
      
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to add money via Solana wallet: ${e.toString()}',
      ));
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<String?> _getAppSolanaWalletAddress() async {
    try {
      // This should be configured in your app settings or environment
      // For now, return a placeholder - replace with your actual app wallet address
      final configService = Get.find<ConfigService>();
      return configService.config.value?.payments.getSolanaWalletAddress ?? ''; // Replace with real address
    } catch (e) {
      Get.log('Error getting app wallet address: $e');
      return null;
    }
  }

  Future<bool> _showSolanaTransactionConfirmation(double solAmount, String recipientAddress) async {
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:  Icon(
                  Icons.account_balance_wallet,
                  color: Get.theme.colorScheme.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Confirm Solana Transaction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Send ${solAmount.toStringAsFixed(4)} SOL to:',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${recipientAddress.substring(0, 8)}...${recipientAddress.substring(recipientAddress.length - 8)}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final exchangeService = Get.find<SolanaExchangeService>();
                final ngnAmount = exchangeService.convertSolToNgn(solAmount);
                return Column(
                  children: [
                    Text(
                      'Estimated NGN: ₦${ngnAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exchangeService.getFormattedRate(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text('Cancel', style: TextStyle(color: Get.theme.colorScheme.primary)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }


  Future<void> _updateWalletBalanceViaApi(double ngnAmount, String transactionSignature, double solAmount) async {
    try {
      // Create transaction data for the backend
      final transactionData = {
        'amount': ngnAmount,
        'transaction_type': 'solana_deposit',
        'solana_transaction_signature': transactionSignature,
        'signature': transactionSignature, // for solana wallet
        'sol_amount': solAmount,
        'exchange_rate': ngnAmount / solAmount,
        'status': 'completed',
        'description': 'Deposit via Solana wallet',
      };

      // Send to backend to update user's wallet balance
      await _walletRepository.addMoneyViaSolana(transactionData);
      
    } catch (e) {
      Get.log('Error updating wallet balance via API: $e');
      // Even if API fails, we can still update locally for better UX
      walletBalance += ngnAmount;
      update();
    }
  }

  // Solana withdrawal methods
  void setWithdrawalType(String type) {
    withdrawalType.value = type;
    // Clear form data when switching types
    if (type == 'solana') {
      selectedBankCode = null;
      accountNumberController.clear();
      accountHolderName = null;
    } else {
      solanaAddressController.clear();
      isSolanaAddressValid.value = false;
    }
    update();
  }

  void validateSolanaAddress(String address) {
    // Basic Solana address validation (Base58, 32-44 characters)
    final isValid = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$').hasMatch(address.trim());
    isSolanaAddressValid.value = isValid;
    update();
  }

  void updateWithdrawalAmount() {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    withdrawalAmount.value = amount;
  }

  Future<void> processSolanaWithdrawal(double amount, String recipientAddress) async {
    try {
      isLoading = true;
      update();

      final exchangeService = Get.find<SolanaExchangeService>();
      
      // Calculate fee and total amount
      final fee = withdrawalFee;
      final totalAmount = amount + fee;
      
      // Convert NGN to SOL using current exchange rate
      final solAmount = exchangeService.convertNgnToSol(amount);
      final feeInSol = exchangeService.convertNgnToSol(fee);
      final totalSolAmount = exchangeService.convertNgnToSol(totalAmount);
      
      // Check if user has sufficient balance
      if (walletBalance < totalAmount) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Insufficient wallet balance. You have ₦${walletBalance.toStringAsFixed(2)}, but need ₦${totalAmount.toStringAsFixed(2)} (including fee)',
        ));
        return;
      }

      // Show confirmation dialog
      final confirmed = await _showSolanaWithdrawalConfirmation(amount, fee, totalAmount, solAmount, feeInSol, totalSolAmount, recipientAddress);
      if (!confirmed) return;

      // Create withdrawal transaction data
      final withdrawalData = {
        'amount': amount,
        'fee': fee,
        'total_amount': totalAmount,
        'withdrawal_type': 'solana',
        'recipient_address': recipientAddress,
        'to_wallet': recipientAddress,
        'sol_amount': solAmount,
        'fee_in_sol': feeInSol,
        'total_sol_amount': totalSolAmount,
        'exchange_rate': amount / solAmount,
        'status': 'pending',
        'description': 'Withdrawal to Solana wallet',
      };

      // Process withdrawal via API
      await _walletRepository.processSolanaWithdrawal(withdrawalData);

      Get.back(); // Close bottom sheet
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: 'Withdrawal request submitted successfully. SOL will be sent to ${recipientAddress.substring(0, 8)}...',
      ));

      await fetchWalletData(); // Refresh wallet data
      
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to process Solana withdrawal: ${e.toString()}',
      ));
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<bool> _showSolanaWithdrawalConfirmation(double ngnAmount, double fee, double totalAmount, double solAmount, double feeInSol, double totalSolAmount, String recipientAddress) async {
    final result = await Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            // color: Get.theme.colorScheme.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:  Icon(
                  Icons.token,
                  color: Get.theme.colorScheme.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
               Text(
                'Confirm Solana Withdrawal',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildConfirmationRow('Amount', '₦${ngnAmount.toStringAsFixed(2)}', '${solAmount.toStringAsFixed(4)} SOL'),
                    const SizedBox(height: 8),
                    _buildConfirmationRow('Fee', '₦${fee.toStringAsFixed(2)}', '${feeInSol.toStringAsFixed(4)} SOL'),
                    const SizedBox(height: 8),
                    _buildConfirmationRow('Total', '₦${totalAmount.toStringAsFixed(2)}', '${totalSolAmount.toStringAsFixed(4)} SOL', isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Send to:',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${recipientAddress.substring(0, 8)}...${recipientAddress.substring(recipientAddress.length - 8)}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final exchangeService = Get.find<SolanaExchangeService>();
                return Text(
                  exchangeService.getFormattedRate(),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    color: Colors.grey[600],
                  ),
                );
              }),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  Widget _buildConfirmationRow(String label, String ngnValue, String solValue, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? Get.theme.colorScheme.primary : null,
          ),
        ),
        Row(
          children: [
            Text(
              ngnValue,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                color: isTotal ? Get.theme.colorScheme.primary : null,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(width: 8),
            Text(
              solValue,
              style: TextStyle(
                fontSize: 14,
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
}
