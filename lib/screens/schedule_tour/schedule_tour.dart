import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/screens/dashboard/widgets/property_card.dart';
import 'package:homy/screens/schedule_tour/controllers/schedule_controller.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:intl/intl.dart';

class ScheduleTourScreen extends StatelessWidget {
  final PropertyData? propertyData;

  const ScheduleTourScreen({super.key, required this.propertyData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScheduleTourScreenController(propertyData));
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern header with property preview and back button
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Get.theme.colorScheme.primary,
                  Get.theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Back button and title row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // iOS-style back button
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        Expanded(
                          child: Text(
                            'Schedule Property Tour',
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Empty SizedBox to balance the back button
                        SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Book your visit time slot',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  // const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  PropertyCard(property: controller.propertyData),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Select Date'),
                        const SizedBox(height: 10),
                        // Modern date selector
                        GetBuilder(
                          init: controller,
                          builder: (controller) {
                            // Get current time in WAT (UTC+1)
                            final now = DateTime.now().toUtc().add(Duration(hours: 1));
                            final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
                            final lastTimeSlot = TimeOfDay(hour: 16, minute: 0);
                            final allTimeSlotsPassed = currentTime.hour >= lastTimeSlot.hour;
                            
                            // If today is disabled and current selected date is today, select tomorrow
                            if (allTimeSlotsPassed && DateUtils.isSameDay(controller.selectDate, now)) {
                              controller.onDateSelected(now.add(Duration(days: 1)));
                            }
                            
                            return Container(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 7, // Show next 7 days
                                itemBuilder: (context, index) {
                                  final date = now.add(Duration(days: index));
                                  final isSelected = DateUtils.isSameDay(date, controller.selectDate);
                                  final isPastDate = date.isBefore(now.subtract(Duration(days: 1)));
                                  final isToday = DateUtils.isSameDay(date, now);
                                  
                                  return InkWell(
                                    onTap: isPastDate || (isToday && allTimeSlotsPassed) ? null : () => controller.onDateSelected(date),
                                    child: Container(
                                      width: 80,
                                      margin: EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? Get.theme.colorScheme.primary 
                                            : isPastDate || (isToday && allTimeSlotsPassed)
                                                ? Get.theme.colorScheme.surface.withOpacity(0.5)
                                                : Get.theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat('EEE').format(date),
                                            style: TextStyle(
                                              color: isSelected 
                                                  ? Colors.white 
                                                  : isPastDate || (isToday && allTimeSlotsPassed)
                                                      ? Get.theme.colorScheme.onSurface.withOpacity(0.5)
                                                      : null,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd').format(date),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected 
                                                  ? Colors.white 
                                                  : isPastDate || (isToday && allTimeSlotsPassed)
                                                      ? Get.theme.colorScheme.onSurface.withOpacity(0.5)
                                                      : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        _buildSectionTitle('Select Time'),
                        const SizedBox(height: 10),
                        // Modern time slots
                        GetBuilder(
                          init: controller,
                          builder: (controller) => Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (var hour in [9, 10, 11, 14, 15, 16])
                                _buildTimeSlot(
                                  context,
                                  TimeOfDay(hour: hour, minute: 0),
                                  controller,
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        _buildSectionTitle('Payment Details'),
                        const SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Get.theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPaymentRow('Tour Booking Fee', '${Constant.currencySymbol} ${controller.propertyData?.tourBookingFee}'),
                              if (controller.configService.config.value?.commissionType == 'percentage')
                                _buildPaymentRow(
                                  'Service Fee (${controller.configService.config.value?.commissionValue}%)',
                                  '${Constant.currencySymbol} ${(double.parse(controller.propertyData?.tourBookingFee ?? '0') * double.parse(controller.configService.config.value?.commissionValue ?? '0') / 100).toStringAsFixed(2)}'
                                )
                              else
                                _buildPaymentRow(
                                  'Service Fee',
                                  '${Constant.currencySymbol} ${controller.configService.config.value?.commissionValue}'
                                ),
                              Divider(height: 20),
                              _buildPaymentRow(
                                'Total',
                                '${Constant.currencySymbol} ${_calculateTotal(controller)}',
                                isTotal: true
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        _buildSectionTitle('Payment Method'),
                        const SizedBox(height: 10),
                        GetBuilder<ScheduleTourScreenController>(
                          builder: (controller) => Column(
                            children: [
                              _buildPaymentMethodCard(
                                icon: Icons.account_balance_wallet,
                                title: 'Pay from Wallet',
                                subtitle: 'Use Wallet Balance',
                                isSelected: controller.selectedPaymentMethod == PaymentMethod.wallet,
                                onTap: () => controller.setPaymentMethod(PaymentMethod.wallet),
                              ),
                              if (controller.configService.config.value?.payments.getEnableCreditCardPayments ?? false)
                              ...[
                               const SizedBox(height: 12),
                                _buildPaymentMethodCard(
                                  icon: Icons.credit_card,
                                  title: 'Pay with Card',
                                  subtitle: 'Add or select card',
                                  isSelected: controller.selectedPaymentMethod == PaymentMethod.card,
                                  onTap: () => controller.setPaymentMethod(PaymentMethod.card),
                                ),
                              ],

                              
                              if (controller.configService.config.value?.payments.getEnableSolanaPayments ?? false)
                              ...[
                                const SizedBox(height: 12),
                                _buildSolanaPaymentCard(controller),
                              ],
                              
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () => controller.onSubmitClick(controller.propertyData),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Get.theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Proceed to Payment',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Get.textTheme.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),

    );
  }

  Widget _buildTimeSlot(BuildContext context, TimeOfDay time, ScheduleTourScreenController controller) {
    final isSelected = time.hour == controller.selectTime.hour;
    final now = DateTime.now().toUtc().add(Duration(hours: 1));
    final isToday = DateUtils.isSameDay(controller.selectDate, now);
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    final isPastTime = isToday && (time.hour < currentTime.hour || (time.hour == currentTime.hour && time.minute <= currentTime.minute));
    final isAvailable = controller.isTimeSlotAvailable(time) && !isPastTime;
    
    return InkWell(
      onTap: isAvailable ? () => controller.onTimeSelected(time) : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? Get.theme.colorScheme.primary 
              : isAvailable 
                  ? Get.theme.colorScheme.surface
                  : Get.theme.colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              MaterialLocalizations.of(context).formatTimeOfDay(time),
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : isAvailable 
                        ? null 
                        : Get.theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
            if (!isAvailable) ...[
              SizedBox(width: 8),
              Icon(
                Icons.lock_clock,
                size: 16,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : null,
              fontFamily: "roboto",
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : null,
              color: isTotal ? Get.theme.colorScheme.primary : null,
              fontFamily: "roboto",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected 
                ? Get.theme.colorScheme.primary 
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
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
                    title,
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: Get.theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotal(ScheduleTourScreenController controller) {
    final tourFee = double.parse(controller.propertyData?.tourBookingFee ?? '0');
    final commissionValue = double.parse(controller.configService.config.value?.commissionValue ?? '0');
    
    if (controller.configService.config.value?.commissionType == 'percentage') {
      final serviceFee = tourFee * commissionValue / 100;
      return (tourFee + serviceFee).toStringAsFixed(2);
    } else {
      return (tourFee + commissionValue).toStringAsFixed(2);
    }
  }

  Widget _buildSolanaPaymentCard(ScheduleTourScreenController controller) {
    return GetBuilder<ScheduleTourScreenController>(
      builder: (controller) {
        final solanaService = Get.find<SolanaWalletService>();
        final isWalletConnected = solanaService.isConnected.value;
        
        return InkWell(
          onTap: () {
            if (!isWalletConnected) {
              _showWalletConnectionDialog();
            } else {
              controller.setPaymentMethod(PaymentMethod.solana);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: controller.selectedPaymentMethod == PaymentMethod.solana 
                    ? Get.theme.colorScheme.primary 
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isWalletConnected 
                        ? Get.theme.colorScheme.primary.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isWalletConnected ? Icons.account_balance : Icons.warning,
                    color: isWalletConnected 
                        ? Get.theme.colorScheme.primary 
                        : Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay with SOL',
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isWalletConnected 
                            ? 'Solana blockchain payment' 
                            : 'Connect wallet to enable SOL payments',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: isWalletConnected 
                              ? Get.theme.colorScheme.onSurface.withOpacity(0.7)
                              : Colors.orange,
                        ),
                      ),
                      if (isWalletConnected) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Balance: ${solanaService.getFormattedBalance()}',
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Get.theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // const SizedBox(height: 2),
                        // _buildCurrencyConversion(controller),

                        

                      ],
                    ],
                  ),
                ),
                if (isWalletConnected)
                  Radio(
                    value: true,
                    groupValue: controller.selectedPaymentMethod == PaymentMethod.solana,
                    onChanged: (_) => controller.setPaymentMethod(PaymentMethod.solana),
                    activeColor: Get.theme.colorScheme.primary,
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.orange,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWalletConnectionDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Get.theme.colorScheme.background,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern header with icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.token,
                  size: 32,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Pay with SOL',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Description
              Text(
                'To pay with SOL, you need to connect your Solana wallet first. This will allow you to make secure blockchain payments.',
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Get.theme.colorScheme.outline.withOpacity(0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed('/wallet-connect');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Connect Wallet',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildCurrencyConversion(ScheduleTourScreenController controller) {
    // Calculate total amount in Naira
    final totalNaira = _calculateTotal(controller);
    final nairaAmount = double.parse(totalNaira);
    
    // Convert Naira to SOL (using approximate exchange rate)
    const double nairaToSolRate = 0.00000352; // Approximate rate: 1 NGN = 0.00015 SOL
    final double solAmount = nairaAmount * nairaToSolRate;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Get.theme.colorScheme.primary.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '₦${nairaAmount.toStringAsFixed(0)}',
            style: Get.textTheme.bodySmall?.copyWith(
              fontFamily: 'roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward,
            size: 12,
            color: Get.theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${solAmount.toStringAsFixed(4)} SOL',
            style: Get.textTheme.bodySmall?.copyWith(

              fontWeight: FontWeight.w500,
              color: Get.theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
