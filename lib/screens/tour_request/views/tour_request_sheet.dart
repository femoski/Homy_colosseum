import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/tour/fetch_property_tour.dart';
import 'package:homy/screens/tour_request/controllers/tour_requests_controller.dart';
import 'package:homy/utils/my_text_style.dart';

import '../../../models/property/tour_request_model.dart';
import 'tour_request_card.dart';

class TourRequestSheet extends StatelessWidget {
  final TourRequestsController controller;
  final FetchPropertyTourData data;

  const TourRequestSheet({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDragHandle(),
                  _buildHeader(),
                  _buildPropertyCard(),
                  const SizedBox(height: 24),
                  _buildStatus(),
                  const SizedBox(height: 24),
                  _buildActions(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 48,
        height: 4,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.onSurface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }


  Widget _buildHeader() {
 return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home_work_outlined,
                  color: Get.theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Property Tour Request',
                  style: MyTextStyle.productBold(
                    size: 24,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if(data.tourStatus == 0) ...[
            Text(
              'Accept or Decline the request to let the user know',
              style: MyTextStyle.productRegular(
                size: 16,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
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

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: data.tourStatus == 0 && data.tourStatus != null 
          ? _buildWaitingActions()
          : data.tourStatus == 1 ? _buildConfirmedActions() : null,
    );
  }


  Widget _buildStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(data.tourStatus != null && data.tourStatus! > 1)...[
        
          Text(
            'Status',
            style: MyTextStyle.productBold(
              size: 18,
              color: Get.theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusCard(),
           const SizedBox(height: 10),

          _buildRefundedActions()
          ],

        ],
      ),
    );
  }



  Widget _buildStatusCard() {
    final statusInfo = _getStatusInfo();
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusInfo.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusInfo.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                statusInfo.icon,
                color: statusInfo.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusInfo.title,
                      style: MyTextStyle.productBold(
                        size: 16,
                        color: statusInfo.color,
                      ),
                    ),
                    const SizedBox(height: 4),
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
         const SizedBox(height: 16),
        _buildDisputeActions(),
      //   if ((data.tourStatus == TourRequestStatus.completed) &&  
      //       data.userConfirmedComplete == false)...[
      //     Column(
      //       children: [
      //         const SizedBox(height: 16),
      //         Row(
      //           children: [
      //                         Expanded(
      //               child: OutlinedButton(
      //                 onPressed: () => controller.openDispute(data),
      //                 style: OutlinedButton.styleFrom(
      //                   foregroundColor: Get.theme.colorScheme.error,
      //                   side: BorderSide(
      //                     color: Get.theme.colorScheme.error,
      //                   ),
      //                   padding: const EdgeInsets.symmetric(vertical: 16),
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(12),
      //                   ),
      //                 ),
      //                 child: Row(
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   children: [
      //                     const Icon(Icons.gavel_rounded),
      //                     const SizedBox(width: 8),
      //                     Text(
      //                       'Open Dispute',
      //                       style: Get.textTheme.bodyLarge?.copyWith(
      //                         fontWeight: FontWeight.w600,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),
      // ]
      ],
    );
  }

  ({Color color, IconData icon, String title, String message}) _getStatusInfo() {

    if(data.tourStatus == 2 && data.completionStatus == 'user_confirmed'){
      return (
        color: Colors.blue,
        icon: Icons.task_alt,
        title: 'Tour Completed',
        message: 'User have confirmed the tour completion and the fund has been released to your Wallet account',
      );
    }


    if(data.tourStatus == 2 && data.completionStatus == 'agent_marked'){
      return (
        color: Colors.blue,
        icon: Icons.task_alt,
        title: 'Awaiting Confirmation',
        message: 'This tour has been marked as completed and is now awaiting the user’s confirmation',
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


           if(data.tourStatus == 2 && data.completionStatus == 'auto_confirmed'){
      return (
        color: Colors.green,
        icon: Icons.task_alt,
          title: 'Tour Completed',
          message: 'The tour has been auto-confirmed and finalized as no dispute was raised within the confirmation period.',
      );
    }

    if(data.tourStatus == 7 && data.completionStatus == 'disputed'){
      return (
        color: Colors.yellow,
        icon: Icons.task_alt,
          title: 'Dispute Opened',
          message: 'The agent has opened a dispute and the funds will be on hold until the dispute is resolved',
      );
    }

    if(data.tourStatus == 7 && data.completionStatus == 'refunded'){
      return (
        color: Colors.blue,
        icon: Icons.task_alt,
          title: 'Tour Request Refunded',
          message: 'The Tour Request has been Refunded and funds has been transfer to User',
      );
    }

        if(data.tourStatus == 7 && data.completionStatus == 'completed'){
      return (
        color: Colors.green,
        icon: Icons.task_alt,
          title: 'Tour Request Completed',
          message: 'The Tour Request has been Completed and funds has been transfer to Agent ',
      );
    }


    switch (data.tourStatus) {
      case 0:
        return (
          color: Colors.orange,
          icon: Icons.schedule,
          title: 'Waiting for Response',
          message: 'Awaiting Your Response',
        );
      // case 1:
      //   return (
      //     color: Colors.green,
      //     icon: Icons.check_circle,
      //     title: 'Request Accepted',
      //     message: 'Your tour has been confirmed for ${data.timeZone}',
      //   );
      // case 4:
      //   return (
      //     color: Colors.red,
      //     icon: Icons.cancel,
      //     title: 'Request Declined',
      //     message: 'You Decline this Tour Request',
      //   );
      // case 3:
      //   return (
      //     color: Colors.blue,
      //     icon: Icons.task_alt,
      //     title: 'Tour Completed',
      //     message: 'This property tour has been completed',
      //   );
        case 7:
        return (
          color: Colors.blue,
          icon: Icons.task_alt,
          title: 'Request Refunded',
          message: 'This property tour has been processed for refund and the funds will be returned to user wallet after 24 hours if no dispute is opened',
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


  Widget _buildWaitingActions() {
    return Column(
      children: [
        _ActionButton(
          onTap: () => controller.onWaitingSheetButtonClick(data, 0,'accept'),
          title: 'Accept Request',
          color: Get.theme.colorScheme.primary,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 12),
        _ActionButton(
          onTap: () => controller.onWaitingSheetButtonClick(data, 1,'decline'),
          title: 'Decline Request',
          color: Get.theme.colorScheme.error,
          icon: Icons.cancel_outlined,
          isOutlined: true,
        ),
      ],
    );
  }

  Widget _buildConfirmedActions() {
    return _ActionButton(
      onTap: () => controller.onWaitingSheetButtonClick(data, 2,'complete'),
      title: 'Mark as Completed',
      color: Get.theme.colorScheme.primary,
      icon: Icons.task_alt_outlined,
    );
  }



    Widget _buildDisputeActions() {
    return Column(
      children: [
        if(data.tourStatus == 2 && data.completionStatus == 'agent_marked')...[
        _ActionButton(
          onTap: () => controller.openDispute(data),
          title: 'Open Dispute',
          color: Get.theme.colorScheme.error,
          icon: Icons.gavel_rounded,
        ),
        const SizedBox(height: 12),
        ],  
        if(data.tourStatus == 2 && data.completionStatus == 'disputed')...[
        _ActionButton(
          onTap: () => controller.viewDisputeStatus(data),
          title: 'View Dispute Status',
          color: Get.theme.colorScheme.primary,
          icon: Icons.gavel_rounded,
        ),
        const SizedBox(height: 12),
        ],  
      ],
    );
  }



    Widget _buildRefundedActions() {
    return Column(
      children: [
        if(data.tourStatus == 7 && data.completionStatus == 'pending')...[
        _ActionButton(
          onTap: () => controller.openDispute(data),
          title: 'Open Dispute',
          color: Get.theme.colorScheme.error,
          icon: Icons.gavel_rounded,
        ),
        const SizedBox(height: 12),
        ],  
        if(data.tourStatus == 7 && data.completionStatus == 'disputed')...[
        _ActionButton(
          onTap: () => controller.viewDisputeStatus(data),
          title: 'View Dispute Status',
          color: Get.theme.colorScheme.primary,
          icon: Icons.gavel_rounded,
        ),
        const SizedBox(height: 12),
        ],  
      ],
    );
  }
}



class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final Color color;
  final IconData icon;
  final bool isOutlined;

  const _ActionButton({
    required this.onTap,
    required this.title,
    required this.color,
    required this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color.withOpacity(0.12),
            border: isOutlined ? Border.all(color: color, width: 2) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
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
