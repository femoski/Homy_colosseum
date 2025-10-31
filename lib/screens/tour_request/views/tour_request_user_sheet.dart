import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/tour/fetch_property_tour.dart';
import 'package:homy/screens/tour_request/controllers/tour_requests_controller.dart';
import 'package:homy/utils/my_text_style.dart';

import 'tour_request_card.dart';

class TourRequestUserSheet extends StatelessWidget {
  final TourRequestsController controller;
  final FetchPropertyTourData data;

  const TourRequestUserSheet({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      _buildPropertyCard(),
                      const SizedBox(height: 28),
                      _buildStatus(),
                      const SizedBox(height: 24),
                      _buildDisputeActions(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.onSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tour Request Details',
            style: MyTextStyle.productBold(
              size: 28,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View the status of your property tour request',
            style: MyTextStyle.productRegular(
              size: 16,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TourRequestCard(data: data),
    );
  }

  Widget _buildStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: MyTextStyle.productBold(
              size: 20,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusCard(),
          if (data.tourStatus == 0) ...[
            const SizedBox(height: 20),
            Obx(() => _ActionButton(
              onTap: () => controller.refundSheetButtonClick(data, 0),
              title: 'Cancel Request',
              color: Get.theme.colorScheme.error,
              icon: Icons.cancel_outlined,
              isOutlined: true,
              isLoading: controller.isRequestLoading.value,
            )),
          ],
          if (data.tourStatus == 1) ...[
            const SizedBox(height: 20),
            Obx(() => _ActionButton(
              onTap: () => controller.refundSheetButtonClick(data, 1),
              title: 'Request Refund',
              color: Get.theme.colorScheme.error,
              icon: Icons.cancel_outlined,
              isOutlined: true,
              isLoading: controller.isRequestLoading.value,
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusInfo = _getStatusInfo();
    
    return Container(
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusInfo.color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusInfo.color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    statusInfo.icon,
                    color: statusInfo.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusInfo.title,
                        style: MyTextStyle.productBold(
                          size: 18,
                          color: statusInfo.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        statusInfo.message,
                        style: MyTextStyle.productRegular(
                          size: 14,
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ({Color color, IconData icon, String title, String message}) _getStatusInfo() {

    if(data.tourStatus == 2 && data.completionStatus == 'user_confirmed'){
      return (
        color: Colors.green,
        icon: Icons.task_alt,
        title: 'Tour Completed',
        message: 'You have confirmed the tour completion and the fund has been released to the agent',
      );
    }

    if(data.tourStatus == 2 && data.completionStatus == 'agent_marked'){
      return (
        color: Colors.blue,
        icon: Icons.task_alt,
        title: 'Tour Completed',
        message: 'The agent has confirmed the tour completion and awaiting your confirmation',
      );
    }

    if(data.tourStatus == 2 && data.completionStatus == 'completed'){
      return (
        color: Colors.green,
        icon: Icons.task_alt,
        title: 'Tour Completed',
        message: 'The tour has been completed and the fund has been released to the agent',
      );
    }

    if(data.tourStatus == 2 && data.completionStatus == 'refunded'){
      return (
        color: Colors.green,
        icon: Icons.task_alt,
        title: 'Tour Completed',
        message: 'The tour has been completed and the fund has been refunded to the user',
      );
    }


    if(data.tourStatus == 2 && data.completionStatus == 'auto_confirmed'){
      return (
        color: Colors.green,
        icon: Icons.task_alt,
        title: 'Tour Completed',
        message: 'The tour has been completed, and the funds have been automatically released to the agent after the system\'s designated timeframe, as no disputes were raised.',
      );
    }
    if(data.tourStatus == 7 && data.completionStatus == 'disputed'){
      return (
        color: Colors.grey,
        icon: Icons.task_alt,
          title: 'Dispute Opened',
          message: 'The agent has opened a dispute and the funds will be on hold until the dispute is resolved',
      );
    }

    if(data.tourStatus == 7 && data.completionStatus == 'refunded'){
      return (
        color: Colors.green,
        icon: Icons.task_alt,
          title: 'Refund Completed',
          message: 'The Tour Request has been Refunded and funds has been transfer to User Wallet',
      );
    }

        if(data.tourStatus == 7 && data.completionStatus == 'completed'){
      return (
        color: Colors.green,
        icon: Icons.task_alt,
          title: 'Refund Completed',
          message: 'The Tour Request has been Refunded and funds has been transfer to Agent Wallet',
      );
    }

       if(data.tourStatus == 2 && data.completionStatus == 'disputed'){
      return (
        color: Colors.grey,
        icon: Icons.task_alt,
          title: 'Dispute Opened',
          message: 'There is an open dispute, and the funds will be on hold until the dispute is resolved.',
      );
    }


    switch (data.tourStatus) {
      case 0:
        return (
          color: Colors.orange,
          icon: Icons.schedule,
          title: 'Waiting for Response',
          message: 'The Agent will review your request soon',
        );
      case 1:
        return (
          color: Colors.green,
          icon: Icons.check_circle,
          title: 'Request Accepted',
          message: 'Your tour has been confirmed for ${data.tourTime}',
        );
      case 2:
        return (
          color: Colors.red,
          icon: Icons.cancel,
          title: 'Request Declined',
          message: 'The Agent has declined your tour request',
        );
      case 3:
        return (
          color: Colors.blue,
          icon: Icons.task_alt,
          title: 'Tour Completed',
          message: 'This property tour has been completed',
        );
      case 7:
        return (
          color: Colors.blue,
          icon: Icons.task_alt,
          title: 'Request Refunded',
          message: 'Your refund request for this property tour has been received. The funds will be returned to your wallet after the system\'s processing period, provided no dispute is opened.',
        );
      default:
        return (
          color: Colors.grey,
          icon: Icons.help_outline,
          title: 'Unknown Status',
          message: 'Unable to determine the current status',
        );
    }
  }

  String _getRemainingTime() {
    // Implementation of _getRemainingTime method
    return ''; // Placeholder return, actual implementation needed
  }

  Widget _buildDisputeActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if(data.tourStatus == 2 && data.completionStatus == 'agent_marked')...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.confirmTourCompletion(data),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.colorScheme.primary,
                      foregroundColor: Get.theme.colorScheme.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded),
                        const SizedBox(width: 8),
                        Text(
                          'Confirm',
                          style: Get.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.openDispute(data),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Get.theme.colorScheme.error,
                      side: BorderSide(
                        color: Get.theme.colorScheme.error,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.gavel_rounded),
                        const SizedBox(width: 8),
                        Text(
                          'Open Dispute',
                          style: Get.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if((data.tourStatus == 7 || data.tourStatus == 2) && data.completionStatus == 'disputed')...[
            _ActionButton(
              onTap: () => controller.viewDisputeStatus(data),
              title: 'View Dispute Status',
              color: Get.theme.colorScheme.primary,
              icon: Icons.gavel_rounded,
            ),
            const SizedBox(height: 12),
          ],  
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final Color color;
  final IconData icon;
  final bool isOutlined;
  final bool isLoading;

  const _ActionButton({
    required this.onTap,
    required this.title,
    required this.color,
    required this.icon,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color.withOpacity(0.08),
            border: isOutlined ? Border.all(color: color, width: 2) : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isOutlined ? null : [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                isLoading ? 'Loading...' : title,
                style: MyTextStyle.productMedium(
                  size: 16,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 