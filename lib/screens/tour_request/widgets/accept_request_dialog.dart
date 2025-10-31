import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/my_text_style.dart';

class AcceptRequestDialog extends StatelessWidget {
  final String propertyTitle;
  final String tourDate;
  final String clientName;
  final VoidCallback onConfirm;
  final bool isLoading;

  const AcceptRequestDialog({
    super.key,
    required this.propertyTitle,
    required this.tourDate,
    required this.clientName,
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
                      _buildRequestInfoSection(),
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
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Accept icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 32,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Accept Tour Request?',
            style: MyTextStyle.productBold(
              size: 20,
              color: Get.theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Confirm this tour request and schedule the visit',
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

  Widget _buildRequestInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.blue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
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
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client',
                    style: MyTextStyle.productMedium(
                      size: 12,
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    clientName,
                    style: MyTextStyle.productBold(
                      size: 20,
                      color: Colors.blue,
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
                  Icons.schedule_outlined,
                  color: Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Tour scheduled for $tourDate',
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
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'By accepting this request, you confirm that you\'re available for the tour and will provide the service as agreed.',
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
          'What happens next:',
          style: MyTextStyle.productBold(
            size: 16,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildTimelineItem(
          Icons.check_circle_outline,
          'Request Accepted',
          'Tour request will be confirmed and client will be notified',
          Colors.green,
          true,
        ),
        _buildTimelineConnector(),
        _buildTimelineItem(
          Icons.schedule_outlined,
          'Tour Scheduled',
          'Tour will be scheduled for the requested date and time',
          Colors.blue,
          false,
        ),
        _buildTimelineConnector(),
        _buildTimelineItem(
          Icons.person_outline,
          'Client Notified',
          'Client will receive confirmation of the accepted tour',
          Colors.orange,
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
              'Review Later',
              style: MyTextStyle.productMedium(size: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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
                    'Accept Request',
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