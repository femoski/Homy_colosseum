import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/my_text_style.dart';

class RefundRequestDialog extends StatelessWidget {
  final String propertyTitle;
  final String tourDate;
  final String tourFee;
  final VoidCallback onConfirm;
  final bool isLoading;

  const RefundRequestDialog({
    super.key,
    required this.propertyTitle,
    required this.tourDate,
    required this.tourFee,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Get.theme.colorScheme.background,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
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
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildRefundAmountCard(),
                      const SizedBox(height: 24),
                      _buildProcessSection(),
                      const SizedBox(height: 24),
                      _buildTimelineSection(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Fixed Action Buttons
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Get.theme.colorScheme.primary.withOpacity(0.1),
            Get.theme.colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Warning icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Get.theme.colorScheme.primary,
              size: 32,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Request Refund?',
            style: MyTextStyle.productBold(
              size: 20,
              color: Get.theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'This action will cancel your tour and refund your payment',
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


  Widget _buildRefundAmountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Get.theme.colorScheme.secondary.withOpacity(0.1),
            Get.theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.colorScheme.secondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.secondary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Get.theme.colorScheme.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Refund Amount',
                    style: MyTextStyle.productMedium(
                      size: 12,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    tourFee,
                    style: MyTextStyle.productBold(
                      size: 20,
                      color: Get.theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Full refund guaranteed',
                  style: MyTextStyle.productMedium(
                    size: 11,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Get.theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Here\'s what happens when you request a refund:',
              style: MyTextStyle.productMedium(
                size: 14,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Refund Timeline:',
          style: MyTextStyle.productBold(
            size: 16,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildTimelineItem(
          Icons.send_outlined,
          'Request Submitted',
          'Your refund request is currently being processed by our system',
          Colors.blue,
          true,
        ),
        _buildTimelineConnector(),
        _buildTimelineItem(
          Icons.schedule_outlined,
          'Review Period',
          'The agent has 24 hours to open a dispute if there are any issues with the cancellation',
          Colors.orange,
          false,
        ),
        _buildTimelineConnector(),
        _buildTimelineItem(
          Icons.account_balance_wallet_outlined,
          'Funds Returned',
          'If no dispute is opened within 24 hours, the amount will be credited to your wallet',
          Colors.green,
          false,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(IconData icon, String title, String subtitle, Color color, bool isActive) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: MyTextStyle.productBold(
                  size: 14,
                  color: isActive ? Get.theme.colorScheme.onSurface : Get.theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: MyTextStyle.productRegular(
                  size: 12,
                  color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector() {
    return Container(
      margin: const EdgeInsets.only(left: 15, top: 6, bottom: 6),
      width: 2,
      height: 16,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.onSurface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => Get.back(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Get.theme.colorScheme.onSurface,
              side: BorderSide(
                color: Get.theme.colorScheme.outline.withOpacity(0.3),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Keep Tour',
              style: MyTextStyle.productMedium(size: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Request Refund',
                    style: MyTextStyle.productMedium(
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
} 