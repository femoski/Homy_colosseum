import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:homy/models/tour/fetch_property_tour.dart';
import 'package:homy/screens/tour_request/controllers/tour_requests_controller.dart';
import 'package:homy/utils/helpers/helper_utils.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/common/widgets/image_widget.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/common/ui.dart';
import 'package:intl/intl.dart';


class EnhancedTourRequestSheet extends StatelessWidget {
  final TourRequestsController controller;
  final FetchPropertyTourData data;

  const EnhancedTourRequestSheet({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // _buildHeader(),
              _buildPropertySection(),
              _buildBookingDetails(),
              // _buildAgentSection(),
              _buildClientSection(),
              _buildPaymentSection(),
              _buildStatusTimeline(),
              _buildStatusCard(),
              _buildActions(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Get.theme.colorScheme.background,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: Get.theme.colorScheme.onSurface,
        ),
      ),
      title: Text(
        'Tour Request Details',
        style: MyTextStyle.productBold(
          size: 18,
          color: Get.theme.colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildStatusChip(),
        ),
      ],
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.home_work_outlined,
                  color: Get.theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request ID: #${data.id}',
                      style: MyTextStyle.productRegular(
                        size: 14,
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tour Request',
                      style: MyTextStyle.productBold(
                        size: 20,
                        color: Get.theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusInfo = _getStatusInfo();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusInfo.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusInfo.title,
        style: MyTextStyle.productBold(
          size: 12,
          color: statusInfo.color,
        ),
      ),
    );
  }

  Widget _buildPropertySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ImageWidget(
                  image: CommonFun.getMedia(
                    m: data.property?.media ?? [],
                    mediaId: 1,
                  ),
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.property?.title ?? 'Property Title',
                    style: MyTextStyle.productBold(size: 18),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Get.theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          data.property?.address ?? 'Address not available',
                          style: MyTextStyle.productRegular(
                            size: 14,
                            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPropertyFeature(Icons.bed, '${data.property?.bedrooms ?? 0} Beds'),
                      const SizedBox(width: 16),
                      _buildPropertyFeature(Icons.bathtub_outlined, '${data.property?.bathrooms ?? 0} Baths'),
                      const SizedBox(width: 16),
                      _buildPropertyFeature(Icons.square_foot, '${data.property?.area ?? 0} sq ft'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: MyTextStyle.productRegular(
            size: 12,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Booking Details', Icons.calendar_today),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Get.theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow('Tour Date', _formatDate(data.createdAt)),
                const SizedBox(height: 8),
                _buildDetailRow('Tour Time', data.tourTime ?? 'Not specified'),
                const SizedBox(height: 8),
                _buildDetailRow('Time Zone', data.timeZone ?? 'Local time'),
                const SizedBox(height: 8),
                _buildDetailRow('Requested On', _formatDate(data.createdAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildClientSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Client Information', Icons.person),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Get.theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
                  child: data.client?.avatar != null
                      ? ClipOval(
                          child: ImageWidget(
                            image: data.client?.avatar ?? '',
                            width: 48,
                            height: 48,
                            borderRadius: 24,
                          ),
                        )
                      : Icon(
                          Icons.person,
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
                        data.client?.name ?? 'Client Name',
                        style: MyTextStyle.productBold(size: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.client?.email ?? 'client@example.com',
                        style: MyTextStyle.productRegular(
                          size: 14,
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                         Text(
                        data.client?.phoneNumber ?? 'Phone Number',
                        style: MyTextStyle.productRegular(
                          size: 14,
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Row(
                      //   children: [
                      //     Icon(
                      //       Icons.verified,
                      //       size: 16,
                      //       color: (data.property?.user?.verificationStatus ?? 0) == 1
                      //           ? Colors.green
                      //           : Colors.grey,
                      //     ),
                      //     const SizedBox(width: 4),
                      //     Text(
                      //       (data.property?.user?.verificationStatus ?? 0) == 1
                      //           ? 'Verified Agent'
                      //           : 'Unverified',
                      //       style: MyTextStyle.productRegular(
                      //         size: 12,
                      //         color: (data.property?.user?.verificationStatus ?? 0) == 1
                      //             ? Colors.green
                      //             : Colors.grey,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement contact agent functionality
                    // Get.showSnackbar(CommonUI.SuccessSnackBar(
                    //   title: 'Contact',
                    //   message: 'Contact feature coming soon!',
                    // ));
                   controller.onMessageClick(data);
                  },

                  icon: Icon(
                    Icons.message,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
                 IconButton(
                  onPressed: () async {
                    // TODO: Implement contact agent functionality

                              if(await canLaunchUrlString('tel:${data.client?.phoneNumber ?? ''} ')) {
                                launchUrlString('tel:${data.client?.phoneNumber ?? ''}');
                              } else {
                                Get.showSnackbar(CommonUI.infoSnackBar(
                                  message: 'Can not launch ${data.client?.phoneNumber ?? ''} '
                                ));
                              }
                                          },
                  icon: Icon(
                    Icons.phone,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAgentSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Agent Information', Icons.person),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Get.theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
                  child: data.property?.user?.avatar != null
                      ? ClipOval(
                          child: ImageWidget(
                            image: data.property?.user?.avatar ?? '',
                            width: 48,
                            height: 48,
                            borderRadius: 24,
                          ),
                        )
                      : Icon(
                          Icons.person,
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
                        data.property?.user?.fullname ?? 'Agent Name',
                        style: MyTextStyle.productBold(size: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.property?.user?.email ?? 'agent@example.com',
                        style: MyTextStyle.productRegular(
                          size: 14,
                          color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: (data.property?.user?.verificationStatus ?? 0) == 1
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (data.property?.user?.verificationStatus ?? 0) == 1
                                ? 'Verified Agent'
                                : 'Unverified',
                            style: MyTextStyle.productRegular(
                              size: 12,
                              color: (data.property?.user?.verificationStatus ?? 0) == 1
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement contact agent functionality
                    Get.showSnackbar(CommonUI.SuccessSnackBar(
                      title: 'Contact',
                      message: 'Contact feature coming soon!',
                    ));
                  },
                  icon: Icon(
                    Icons.message,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Payment Details', Icons.payment),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Get.theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                _buildPaymentRow('Tour Fee', '${data.property?.tourBookingFee ?? '1000'}'),
                const SizedBox(height: 8),
                // _buildPaymentRow('Platform Fee', '${data.payment?.paymentAmount ?? '1000'}'),
                // const SizedBox(height: 8),
                // _buildPaymentRow('Total Amount', '\$${(int.tryParse(data.payment?.paymentAmount ?? '1000') ?? 1000) + 50}'),
                // const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Payment ${data.payment?.paymentStatus?.toCapitalized() ?? 'Pending'}',
                        style: MyTextStyle.productBold(
                          size: 12,
                          color: Colors.green,
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

  Widget _buildPaymentRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: MyTextStyle.productRegular(
            size: 14,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          amount,
          style: MyTextStyle.productBold(
            size: 14,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }



  Widget _buildStatusCard() {
    final statusInfo = _getStatusInfo();
        
    return Column(
      children: [
        Padding( padding: const EdgeInsets.fromLTRB(24, 20, 24, 0), child: 
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
        ),

      ],
    );
  }

  Widget _buildStatusText() {
    final statusInfo = _getStatusInfo();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Text(
        'Status: ${statusInfo.title}',
        style: MyTextStyle.productBold(size: 16),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Status Timeline', Icons.timeline),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Get.theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                _buildTimelineItem(
                  'Request Submitted',
                  _formatDate(data.createdAt),
                  Icons.send,
                  Colors.blue,
                  true,
                ),
                _buildTimelineItem(
                  'Agent Reviewing',
                  'In Progress',
                  Icons.pending,
                  Colors.orange,
                  data.tourStatus == 0,
                ),
                _buildTimelineItem(
                  'Tour Confirmed',
                  'Confirmed',
                  Icons.check_circle,
                  Colors.green,
                  data.tourStatus == 1,
                ),
                // if (data.completionStatus == 'disputed') ...[
                //   _buildTimelineItem(
                //     'Dispute Opened',
                //     'Disputed',
                //     Icons.gavel_rounded,
                //     Colors.red,
                //     data.tourStatus == 7 && data.completionStatus == 'disputed',
                //   ),
                // ],
                if (data.tourStatus == 4) ...[
                   _buildTimelineItem(
                  'Tour Declined',
                  'Declined',
                  Icons.cancel,
                  Colors.red,
                  data.tourStatus == 4 && data.completionStatus == 'refunded',
                ),
                ],


                         if (data.tourStatus == 3) ...[
                   _buildTimelineItem(
                  'Tour Cancelled',
                  'Cancelled',
                  Icons.cancel,
                  Colors.red,
                  data.tourStatus == 3,
                ),
                ],
                
                          if (data.completionStatus == 'disputed') ...[
                  _buildTimelineItem(
                    'Dispute Opened',
                    'Disputed',
                    Icons.gavel_rounded,
                    Colors.red,
                     data.completionStatus == 'disputed',
                  ),
                ],
                _buildTimelineItem(
                  'Tour Completed',
                  'Completed',
                  Icons.task_alt,
                  Colors.green,
                  (data.tourStatus == 2 && data.completionStatus != 'disputed') || (data.completionStatus == 'to_user' || data.completionStatus == 'to_agent' || data.completionStatus == 'completed'),
                ),

    if(data.completionStatus == 'to_user' || data.completionStatus == 'to_agent') ...[
                  _buildTimelineItem(
                  'Dispute Resolved',
                  'Resolved',
                  Icons.check_circle,
                  const Color(0xFF1abc9c),
                  (data.completionStatus == 'to_user' || data.completionStatus == 'to_agent'),
                ),
]
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, IconData icon, Color color, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey,
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
                    color: isCompleted ? Get.theme.colorScheme.onSurface : Get.theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
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
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          if (data.tourStatus == 0) ...[
            Obx(() => _buildActionButton(
              'Accept Request',
              Icons.check_circle_outline,
              Get.theme.colorScheme.primary,
              () => controller.showAcceptRequestDialog(data),
              // () => controller.onWaitingSheetButtonClick(data, 0, 'accept'),
              isLoading: controller.isRequestLoading.value,
            )),
            const SizedBox(height: 12),
            Obx(() => _buildActionButton(
              'Decline Request',
              Icons.cancel_outlined,
              Get.theme.colorScheme.error,
              () => controller.showDeclineRequestDialog(data),
              // () => controller.onWaitingSheetButtonClick(data, 1, 'decline'),
              isOutlined: true,
              isLoading: controller.isRequestLoading.value,
            )),
          ],
          if (data.tourStatus == 1) ...[
            Obx(() => _buildActionButton(
              'Mark as Completed',
              Icons.task_alt_outlined,
              Get.theme.colorScheme.primary,
              () => controller.showMarkTourCompletedDialog(data),
              isLoading: controller.isRequestLoading.value,
            )),
          ],
          if (data.tourStatus == 2 && data.completionStatus == 'agent_marked') ...[
            Obx(() => _buildActionButton(
              'Open Dispute',
              Icons.gavel_rounded,
              Get.theme.colorScheme.error,
              () => controller.openDispute(data),
              isLoading: controller.isRequestLoading.value,
            )),
          ],
            if (data.tourStatus == 7 && data.completionStatus == 'pending') ...[
            Obx(() => _buildActionButton(
              'Open Dispute',
              Icons.gavel_rounded,
              Get.theme.colorScheme.error,
              () => controller.openDispute(data),
              isLoading: controller.isRequestLoading.value,
            )),
          ],

          if (data.tourStatus == 7 && data.completionStatus == 'disputed') ...[
            Obx(() => _buildActionButton(
              'View Dispute Status',
              Icons.gavel_rounded,
              Get.theme.colorScheme.primary,
              () => controller.viewDisputeStatus(data),
              isLoading: controller.isRequestLoading.value,
            )),
          ],
          const SizedBox(height: 12),
          _buildActionButton(
            'View Property Details',
            Icons.home_outlined,
            Get.theme.colorScheme.secondary,
            () {
              Get.back();
              Get.toNamed('/property-details/${data.property?.id ?? -1}', arguments: {
                'propertyId': data.property?.id,
                'propertiesList': [],
                'fromMyProperty': false,
              });
            },
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap, {bool isOutlined = false, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : color,
          foregroundColor: isOutlined ? color : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutlined ? BorderSide(color: color, width: 1) : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: MyTextStyle.productBold(size: 16),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Get.theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: MyTextStyle.productBold(
            size: 18,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: MyTextStyle.productRegular(
            size: 14,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: MyTextStyle.productBold(
            size: 14,
            color: Get.theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'Not available';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }


  ({Color color, IconData icon, String title, String message}) _getStatusInfo() {


  if(data.tourStatus == 1 && data.completionStatus == 'pending'){
      return (
        color: Colors.blue,
        icon: Icons.task_alt,
        title: 'Tour Request in Progress',
        message: 'The tour has been confirmed and is now in progress',
      );
    }


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
        message: 'This tour has been marked as completed and is now awaiting the user’s confirmation, if no dispute is opened within 24 hours, the funds will be automatically released to the agent',
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
        color: Colors.grey,
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


    if(data.tourStatus == 2 && data.completionStatus == 'refunded'){
      return (
        color: Colors.blue,
        icon: Icons.task_alt,
          title: 'Tour Request Refunded',
          message: 'The Tour Request has been Refunded and funds has been transfer to User',
      );
    }

        if(data.tourStatus == 2 && data.completionStatus == 'to_user'){
      return (
          color: const Color(0xFF1abc9c),
        icon: Icons.task_alt,
        title: 'Dispute Resolved',
        message: 'The dispute has been resolved and the funds have been transferred to your user wallet account',
      );
    }

    if(data.tourStatus == 2 && data.completionStatus == 'to_agent'){
      return (
        color: const Color(0xFF1abc9c),
        icon: Icons.task_alt,
        title: 'Dispute Resolved',
        message: 'The dispute has been resolved and the funds have been transferred to the agent wallet account',
      );
    }


        if(data.tourStatus == 4 && data.completionStatus == 'refunded'){
      return (
        color: Colors.red,
        icon: Icons.cancel,
          title: 'Tour Request Declined',
          message: 'The Tour Request has been Declined and funds has been transfer to User',
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


        if(data.tourStatus == 7 && data.completionStatus == 'to_agent'){
      return (
        color: Colors.green,
        icon: Icons.task_alt,
        title: 'Tour Request Completed',
        message: 'The dispute has been resolved and the funds have been transferred to the agent',
      );
    }

        if(data.tourStatus == 7 && data.completionStatus == 'to_user'){
      return (
        color: const Color(0xFF1abc9c),
        icon: Icons.task_alt,
        title: 'Dispute Resolved',
        message: 'The dispute has been resolved and the funds have been transferred to the user',
      );
    }

      if(data.tourStatus == 3){
      return (
        color: Colors.red,
        icon: Icons.task_alt,
        title: 'Tour Request Cancelled',
        message: 'The Tour Request has been Cancelled and funds has been transfer to User',
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
      case 4:
        return (
          color: Colors.red,
          icon: Icons.cancel,
          title: 'Request Declined',
          message: 'You Decline this Tour Request and the user has been notified and refund has been processed',
        );
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



  _StatusInfo _getStatusInfoa() {
    if (data.tourStatus == 2 && data.completionStatus == 'user_confirmed') {
      return _StatusInfo(
        color: Colors.green,
        icon: Icons.task_alt,
        title: 'Completed',
        message: 'Tour completed and funds released',
      );
    }

    if (data.tourStatus == 2 && data.completionStatus == 'agent_marked') {
      return _StatusInfo(
        color: Colors.blue,
        icon: Icons.pending,
        title: 'Awaiting Confirmation',
        message: 'Agent marked as completed, waiting for user confirmation',
      );
    }

    if (data.tourStatus == 2 && data.completionStatus == 'disputed') {
      return _StatusInfo(
        color: Colors.orange,
        icon: Icons.gavel,
        title: 'Disputed',
        message: 'Dispute opened, funds on hold',
      );
    }

    switch (data.tourStatus) {
      case 0:
        return _StatusInfo(
          color: Colors.orange,
          icon: Icons.schedule,
          title: 'Pending',
          message: 'Waiting for agent response',
        );
      case 1:
        return _StatusInfo(
          color: Colors.green,
          icon: Icons.check_circle,
          title: 'Confirmed',
          message: 'Tour has been confirmed',
        );
      case 3:
        return _StatusInfo(
          color: Colors.red,
          icon: Icons.cancel,
          title: 'Declined',
          message: 'Tour request was declined',
        );
      case 7:
        return _StatusInfo(
          color: Colors.blue,
          icon: Icons.refresh,
          title: 'Refunded',
          message: 'Tour has been refunded',
        );
      default:
        return _StatusInfo(
          color: Colors.grey,
          icon: Icons.help_outline,
          title: 'Unknown',
          message: 'Status unknown',
        );
    }
  }
}

class _StatusInfo {
  final Color color;
  final IconData icon;
  final String title;
  final String message;

  _StatusInfo({
    required this.color,
    required this.icon,
    required this.title,
    required this.message,
  });
} 