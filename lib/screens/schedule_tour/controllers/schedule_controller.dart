import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/repositories/properties_respository.dart';
import 'package:homy/services/config_service.dart';
import 'package:homy/screens/payment/payment_webview_screen.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:homy/services/solana_exchange_service.dart';

enum PaymentMethod { wallet, card, solana }

class ScheduleTourScreenController extends GetxController {
  final PropertyData? propertyData;
  final ConfigService configService = Get.find<ConfigService>();

  
  DateTime selectDate = DateTime.now();
  TimeOfDay selectTime = TimeOfDay(hour: 9, minute: 0);
  PaymentMethod selectedPaymentMethod = PaymentMethod.wallet;
  final propertiesRepository = PropertiesRepository();

  double walletBalance = 150.0; // You should get this from your backend

  // Available time slots
  final List<TimeOfDay> timeSlots = [
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
  ];

  // final settingsService = Get.find<SettingsService>();

  ScheduleTourScreenController(this.propertyData) {
    // Initialize with the first available time slot for today
    if (DateUtils.isSameDay(selectDate, DateTime.now())) {
      selectTime = _getFirstAvailableTimeSlot();
    }
  }

  void onDateSelected(DateTime date) {
    if (date.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      return; // Prevent selecting past dates
    }

    selectDate = date;
    // Reset time selection for the new date
    if (DateUtils.isSameDay(date, DateTime.now())) {
      selectTime = _getFirstAvailableTimeSlot();
    } else {
      selectTime = timeSlots.first;
    }
    update();
  }

  void onTimeSelected(TimeOfDay time) {
    if (!isTimeSlotAvailable(time)) return;
    selectTime = time;
    update();
  }

  bool isTimeSlotAvailable(TimeOfDay time) {
    if (!DateUtils.isSameDay(selectDate, DateTime.now())) {
      return true;
    }

    final now = TimeOfDay.now();
    // Convert to minutes since midnight for easier comparison
    final timeInMinutes = time.hour * 60 + time.minute;
    final nowInMinutes = now.hour * 60 + now.minute;

    // Add buffer time (e.g., 30 minutes from now)
    return timeInMinutes > (nowInMinutes + 30);
  }

  TimeOfDay _getFirstAvailableTimeSlot() {
    return timeSlots.firstWhere(
      (slot) => isTimeSlotAvailable(slot),
      orElse: () => timeSlots.first,
    );
  }

  void setPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod = method;
    update();
  }

  Future<void> onSubmitClick(PropertyData? propertyData) async {
    try {
      // Check if Solana payment is selected but wallet is not connected
      if (selectedPaymentMethod == PaymentMethod.solana) {
        final solanaService = Get.find<SolanaWalletService>();
        if (!solanaService.isConnected.value) {
          Get.showSnackbar(CommonUI.ErrorSnackBar(
            message: 'Please connect your Solana wallet first to proceed with SOL payment.',
          ));
          return;
        }
      }

      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        // barrierDismissible: false,
      );
      
      final success = await _processCardPayment();
      
    //  Get.log('ssssaasuccessaaaaaa: $success');
      // Close loading dialog
      Get.back();

      if (success) {
        await showSuccessDialog();
      } else {
        await showFailureDialog();
      }
    } catch (e) {
      if (e.toString().contains('Insufficient')) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
        // 'Insufficient balance. Please add money to your wallet or choose a different payment method.'
      } else {
        Get.showSnackbar(CommonUI.ErrorSnackBar(message: 'failed to process payment. Please try again. $e'));
      }
    }
  }

  Future<bool> _processCardPayment() async {
    if (selectedPaymentMethod == PaymentMethod.solana) {
      return await _processSolanaPayment();
    }
    
    // Get payment authorization URL from backend
    final response = await propertiesRepository.scheduleTour(params: {
      'property_id': propertyData?.id.toString(),
      'agent_id': propertyData?.user?.id.toString(),
      'tour_date': selectDate.toString(),
      'tour_time': selectTime.format(Get.context!),
      'payment_method': selectedPaymentMethod.name,
    });

    Get.log('responseresponseresponseresponse: $response');

    if (response['authorization_url'] != null) {
      final result = await Get.to<bool>(() => PaymentWebViewScreen(
                authorizationUrl: response['authorization_url'],
                onComplete: (success) {
                  Get.log('Payment completed with success: $success');
                },
              ));
      Get.log('Payment result from navigation: $result');
      return result ?? false;
    }
    else if(response['status'] == 'success') {
      Get.back();
      return true;
    }
     else if (response['status'] == 400) {
      Get.back();
      // Get.showSnackbar(CommonUI.ErrorSnackBar(message: response['message']));
      throw (response['message']);
    }
    return false;
  }

  Future<bool> _processSolanaPayment() async {
    try {
      final solanaService = Get.find<SolanaWalletService>();
      
      if (!solanaService.isConnected.value) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Please connect your Solana wallet first',
        ));
        return false;
      }

      // Calculate total amount
      final totalAmount = _calculateTotalAmount();
      
      // Show Solana payment dialog
      final result = await _showSolanaPaymentDialog(totalAmount);
      
      if (result != null && result != false) {
        // Process the tour booking after successful payment
        final response = await propertiesRepository.scheduleTour(params: {
          'property_id': propertyData?.id.toString(),
          'agent_id': propertyData?.user?.id.toString(),
          'tour_date': selectDate.toString(),
          'tour_time': selectTime.format(Get.context!),
          'payment_method': 'solana',
          'tx_hash': result,
        });

        if (response['status'] == 'success') {
          return true;
        } else {
          throw Exception(response['message'] ?? 'Failed to schedule tour');
        }
      }
      
      return false;
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Solana payment failed: ${e.toString()}',
      ));
      return false;
    }
  }

  double _calculateTotalAmount() {
    final tourFee = double.parse(propertyData?.tourBookingFee ?? '0');
    final commissionValue = double.parse(configService.config.value?.commissionValue ?? '0');
    
    if (configService.config.value?.commissionType == 'percentage') {
      final serviceFee = tourFee * commissionValue / 100;
      return tourFee + serviceFee;
    } else {
      return tourFee + commissionValue;
    }
  }

  Future<dynamic?> _showSolanaPaymentDialog(double nairaAmount) async {
    final solanaService = Get.find<SolanaWalletService>();
    
    // Convert Naira to SOL (using approximate exchange rate)
    // In a real app, you'd fetch this from an API

    final exchangeService = Get.find<SolanaExchangeService>();
    final nairaToSolRate = exchangeService.currentRate.value;
    final double solAmount = nairaAmount / nairaToSolRate;
    
    final amountController = TextEditingController(text: solAmount.toStringAsFixed(6));
    // final agentWalletController = TextEditingController(
    //   text: '6SDS7uG9sVXbVmtZZQ99GXenYk5FMFFdFw8rGTtBFCBW', // Default agent wallet
    // );
    final agentWalletController = TextEditingController(
      text: configService.config.value?.payments.getSolanaWalletAddress ?? '',
    );


    return await Get.dialog<dynamic>(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Get.isDarkMode ? 15 : 10),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Get.theme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay with Solana',
                          style: Get.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                        Text(
                          propertyData?.title ?? 'Unknown Property',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: Get.theme.primaryColor.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Amount conversion
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(Get.isDarkMode ? 15 : 10),
                  border: Border.all(
                    color: Get.theme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount in Naira:',
                          style: Get.textTheme.bodyMedium,
                        ),
                        Text(
                          '₦${nairaAmount.toStringAsFixed(2)}',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Get.theme.primaryColor,
                            fontFamily: 'roboto',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount in SOL:',
                          style: Get.textTheme.bodyMedium,
                        ),
                        Text(
                          '${solAmount.toStringAsFixed(6)} SOL',
                          style: Get.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rate: ${exchangeService.getFormattedRate()}",
                      style: Get.textTheme.bodySmall?.copyWith(
                        fontFamily: 'roboto',
                        color: Get.theme.primaryColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Wallet address field
              TextField(
                controller: agentWalletController,
                decoration: InputDecoration(
                  labelText: 'Agent Wallet Address',
                  hintText: 'Agent wallet address',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  enabled: false,
                  labelStyle: Get.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'roboto',
                  ),
                ),
              ),
              
              // const SizedBox(height: 16),
              
              // SOL amount field
              // TextField(
              //   controller: amountController,
              //   decoration: InputDecoration(
              //     labelText: 'Amount (SOL)',
              //     hintText: '0.000000',
              //     prefixIcon: const Icon(Icons.currency_exchange),
              //     helperText: 'Amount automatically converted from Naira',
              //   ),
              //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
              // ),
              
              // const SizedBox(height: 16),
              
              // Balance display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(Get.isDarkMode ? 15 : 10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Get.theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Balance: ',
                      style: Get.textTheme.bodyMedium,
                    ),
                    Obx(() => Text(
                      solanaService.getFormattedBalance(),
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Get.theme.primaryColor,
                      ),
                    )),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Get.theme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (amountController.text.isNotEmpty) {
                          // Get.back();
                          final solAmount = double.tryParse(amountController.text) ?? 0.0;
                          final enableSolanaPayments = configService.config.value?.payments.getEnableSolanaPayments ?? false;
                          final solanaWalletAddress = configService.config.value?.payments.getSolanaWalletAddress ?? '';
                          
                          if (solAmount > 0 && enableSolanaPayments && solanaWalletAddress.isNotEmpty) {
                            final signature = await solanaService.sendPayment(
                              recipientAddress: solanaWalletAddress,
                              solAmount: solAmount,
                              memo: 'Property tour booking for ${propertyData?.title}',
                            );
                            
                            if (signature != null) {
                              // Mint NFT certificate after successful payment
                              // final nftData = {
                              //   'title': propertyData?.title ?? 'Property',
                              //   'description': 'Property tour booking certificate',
                              //   'imageUrl': propertyData?.media?.isNotEmpty == true 
                              //       ? propertyData!.media!.first.content 
                              //       : '',
                              //   'propertyId': propertyData?.id.toString() ?? '',
                              // };
                              // Get.showSnackbar(CommonUI.SuccessSnackBar(
                              //   message: 'Payment successful',
                              // ));
                              // await solanaService.mintNFTCertificate(nftData);

                              Get.back(result: signature);
                              Get.back(result: signature);
                            } else {
                              Get.back(result: false);
                            }
                          }
                        }
                      },
                      child: const Text('Pay with SOL'),
                    ),
                  ),
                ],
              ),
                ],
              ),
            ),
          ),
        ),
      );
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
                  'Tour Scheduled!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your property tour has been scheduled successfully. Check your email for confirmation details.',
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
                        Get.back(); // Close dialog
                        Get.back(); // Return to previous screen
                      },
                      child: Text(
                        'View Bookings',
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


  // bool get isWalletEnabled =>
  //     settingsService.getModuleOption<bool>('Payment', 'wallet_enabled') ??
  //     false;

  // double get serviceFee =>
  //     settingsService.getModuleOption<double>('Payment', 'service_fee') ?? 10.0;

  // double get minimumBalance =>
  //     settingsService.getModuleOption<double>('Payment', 'minimum_balance') ??
  //     50.0;
}
