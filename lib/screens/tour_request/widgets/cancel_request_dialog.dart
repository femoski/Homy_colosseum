import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/my_text_style.dart';

class CancelRequestDialog extends StatelessWidget {
  final String propertyTitle;
  final String tourDate;
  final VoidCallback onConfirm;
  final bool isLoading;

  const CancelRequestDialog({
    super.key,
    required this.propertyTitle,
    required this.tourDate,
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
                      _buildWarningSection(),
                      const SizedBox(height: 24),
                      _buildConsequencesSection(),
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
            Get.theme.colorScheme.error.withOpacity(0.1),
            Get.theme.colorScheme.error.withOpacity(0.05),
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
              color: Get.theme.colorScheme.error.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Get.theme.colorScheme.error,
              size: 32,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Cancel Tour Request?',
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

  Widget _buildWarningSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.colorScheme.error.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Get.theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'By cancelling this tour request, you acknowledge the consequences below.',
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

  Widget _buildConsequencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What happens when you cancel:',
          style: MyTextStyle.productBold(
            size: 16,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildConsequenceItem(
          Icons.money_off_outlined,
          'Full Refund',
          'Tour fee will be refunded to your wallet Instantly',
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildConsequenceItem(
          Icons.schedule_outlined,
          'Immediate Cancellation',
          'Tour will be cancelled and agent will be notified',
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildConsequenceItem(
          Icons.history_outlined,
          'Cannot Be Undone',
          'This action is permanent and cannot be reversed',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildConsequenceItem(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
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
                    color: Get.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: MyTextStyle.productRegular(
                    size: 12,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              'Keep Request',
              style: MyTextStyle.productMedium(size: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
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
                    'Cancel Request',
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