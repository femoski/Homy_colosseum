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
import 'package:homy/models/nft_property_model.dart';
import 'package:homy/models/property_model.dart';
import 'package:homy/services/nft_marketplace_service.dart';
import 'package:homy/services/solana_wallet_service.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class EnhancedTourRequestUserSheet extends StatelessWidget {
  final TourRequestsController controller;
  final FetchPropertyTourData data;

  const EnhancedTourRequestUserSheet({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      appBar: _buildAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildSpeedDial(context),
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

  Widget _buildSpeedDial(BuildContext context) {
    final bool isTourCompleted = data.tourStatus == 2 &&
        (data.completionStatus == 'user_confirmed' ||
            data.completionStatus == 'auto_confirmed' ||
            data.completionStatus == 'to_agent' ||
            data.completionStatus == 'completed');

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Get.theme.colorScheme.primary,
      foregroundColor: Get.theme.colorScheme.onPrimary,
      overlayColor: Colors.black,
      overlayOpacity: 0.35,
      spacing: 12,
      children: [
        if (isTourCompleted &&
                ((data.property?.paymentStatus == true ||
                    data.property?.isPaidByUser == true)) ||
            (data.property?.paymentStatus == false)) ...[
          SpeedDialChild(
            onTap: isTourCompleted ? _payForProperty : null,
            labelWidget: _actionLabel(
              icon: Icons.payment_outlined,
              label: 'Pay for Property',
              // enabled: data.property?.isPaidByUser != true,
            ),
          ),
        ],
        SpeedDialChild(
          onTap: isTourCompleted ? () => _openReviewSheet(context) : null,
          labelWidget: _actionLabel(
            icon: Icons.rate_review_outlined,
            label: 'Give Review',
          ),
        ),
      ],
    );
  }

  Widget _actionLabel(
      {required IconData icon, required String label, bool enabled = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 25,
              color: enabled
                  ? Get.theme.colorScheme.onPrimary
                  : Get.theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 12),
          Text(
            label,
            style: MyTextStyle.productMedium(
              color: enabled
                  ? Get.theme.colorScheme.onPrimary
                  : Get.theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          if (!enabled) ...[
            const SizedBox(width: 8),
            Text(
              '(after completion)',
              style: MyTextStyle.productRegular(
                size: 11,
                color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ],
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
        'My Tour Request',
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

  Widget _buildFloatingActions(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickActions(context),
      backgroundColor: Get.theme.colorScheme.primary,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.more_horiz),
      label: const Text('Actions'),
    );
  }

  void _showQuickActions(BuildContext context) {
    final bool isTourCompleted = data.tourStatus == 2 &&
        (data.completionStatus == 'user_confirmed' ||
            data.completionStatus == 'auto_confirmed' ||
            data.completionStatus == 'to_agent' ||
            data.completionStatus == 'completed');

    showModalBottomSheet(
      context: context,
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.payment_outlined,
                    color: isTourCompleted
                        ? Get.theme.colorScheme.primary
                        : Get.theme.colorScheme.onSurface.withOpacity(0.4)),
                title: const Text('Pay for Property'),
                subtitle: isTourCompleted
                    ? null
                    : const Text('Available after tour completion'),
                enabled: isTourCompleted,
                onTap: () {
                  Get.back();
                  _payForProperty();
                },
              ),
              ListTile(
                leading: Icon(Icons.rate_review_outlined,
                    color: isTourCompleted
                        ? Get.theme.colorScheme.primary
                        : Get.theme.colorScheme.onSurface.withOpacity(0.4)),
                title: const Text('Give Review'),
                subtitle: isTourCompleted
                    ? null
                    : const Text('Available after tour completion'),
                enabled: isTourCompleted,
                onTap: () {
                  Get.back();
                  _openReviewSheet(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _payForProperty() async {
    if (data.property == null) {
      Get.showSnackbar(
          CommonUI.ErrorSnackBar(message: 'Property details unavailable'));
      return;
    }

    Get.toNamed(
      '/property-payment',
      arguments: {
        'property': data,
      },
    );
  }

  void _openReviewSheet(BuildContext context) {
    final TextEditingController reviewController = TextEditingController();
    int rating = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Give Review',
                      style: MyTextStyle.productBold(
                          size: 18, color: Get.theme.colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (index) {
                      final filled = index < rating;
                      return IconButton(
                        onPressed: () => setState(() => rating = index + 1),
                        icon: Icon(
                          filled ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share details about your experience...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Hook API to submit review with rating and text
                        Get.back();
                        Get.showSnackbar(CommonUI.SuccessSnackBar(
                            message: 'Thanks for your review!'));
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        );
      },
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
                      'My Tour Request',
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
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
                            color: Get.theme.colorScheme.onSurface
                                .withOpacity(0.7),
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
                      _buildPropertyFeature(
                          Icons.bed, '${data.property?.bedrooms ?? 0} Beds'),
                      const SizedBox(width: 16),
                      _buildPropertyFeature(Icons.bathtub_outlined,
                          '${data.property?.bathrooms ?? 0} Baths'),
                      const SizedBox(width: 16),
                      _buildPropertyFeature(Icons.square_foot,
                          '${data.property?.area ?? 0} sq ft'),
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
                  backgroundColor:
                      Get.theme.colorScheme.primary.withOpacity(0.1),
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
                        data.property?.user?.fullname ?? 'My Name',
                        style: MyTextStyle.productBold(size: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.property?.user?.email ?? 'myemail@example.com',
                        style: MyTextStyle.productRegular(
                          size: 14,
                          color:
                              Get.theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.property?.user?.mobileNo ?? 'My Phone Number',
                        style: MyTextStyle.productRegular(
                          size: 14,
                          color:
                              Get.theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    controller.onMessageClickAgent(data);
                  },
                  icon: Icon(
                    Icons.message,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    // TODO: Implement contact agent functionality
                    if (await canLaunchUrlString(
                        'tel:${data.property?.user?.mobileNo ?? ''} ')) {
                      launchUrlString(
                          'tel:${data.property?.user?.mobileNo ?? ''}');
                    } else {
                      Get.showSnackbar(CommonUI.infoSnackBar(
                          message:
                              'Can not launch ${data.property?.user?.mobileNo ?? ''} '));
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
                  backgroundColor:
                      Get.theme.colorScheme.primary.withOpacity(0.1),
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
                          color:
                              Get.theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: (data.property?.user?.verificationStatus ??
                                        0) ==
                                    1
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
                              color: (data.property?.user?.verificationStatus ??
                                          0) ==
                                      1
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
                IconButton(
                  onPressed: () async {
                    // TODO: Implement contact agent functionality
                    if (await canLaunchUrlString(
                        'tel:${data.client?.phoneNumber ?? ''} ')) {
                      launchUrlString('tel:${data.client?.phoneNumber ?? ''}');
                    } else {
                      Get.showSnackbar(CommonUI.infoSnackBar(
                          message:
                              'Can not launch ${data.client?.phoneNumber ?? ''} '));
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
                _buildPaymentRow(
                    'Tour Fee', '${data.property?.tourBookingFee ?? '1000'}'),
                const SizedBox(height: 8),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Container(
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
                          color:
                              Get.theme.colorScheme.onSurface.withOpacity(0.7),
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
                if (data.completionStatus == 'disputed') ...[
                  _buildTimelineItem(
                    'Dispute Opened',
                    'Disputed',
                    Icons.gavel_rounded,
                    Colors.red,
                    data.completionStatus == 'disputed',
                  ),
                ],
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
                _buildTimelineItem(
                  'Tour Completed',
                  'Completed',
                  Icons.task_alt,
                  Colors.green,
                  (data.tourStatus == 2 &&
                          data.completionStatus != 'disputed') ||
                      (data.completionStatus == 'to_user' ||
                          data.completionStatus == 'to_agent' ||
                          data.completionStatus == 'completed'),
                ),
                if (data.completionStatus == 'to_user' ||
                    data.completionStatus == 'to_agent') ...[
                  _buildTimelineItem(
                    'Dispute Resolved',
                    'Resolved',
                    Icons.check_circle,
                    const Color(0xFF1abc9c),
                    (data.completionStatus == 'to_user' ||
                        data.completionStatus == 'to_agent'),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseNFTSection() {
    final bool isTourCompleted = data.tourStatus == 2 &&
        (data.completionStatus == 'user_confirmed' ||
            data.completionStatus == 'auto_confirmed' ||
            data.completionStatus == 'to_agent' ||
            data.completionStatus == 'completed');

    if (!isTourCompleted) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ownership & NFT', Icons.verified),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Get.theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pay for the property and mint your ownership NFT. You can view or claim it in My NFTs after minting.',
                        style: MyTextStyle.productRegular(
                          size: 14,
                          color:
                              Get.theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Connect wallet if needed
                Obx(() {
                  final walletConnected =
                      SolanaWalletService.to.isConnected.value;
                  if (walletConnected) return const SizedBox.shrink();
                  return _buildActionButton(
                    'Connect Wallet',
                    Icons.link,
                    Get.theme.colorScheme.primary,
                    () async {
                      try {
                        await SolanaWalletService.to.connectWallet();
                      } catch (e) {
                        Get.showSnackbar(
                            CommonUI.ErrorSnackBar(message: e.toString()));
                      }
                    },
                    isOutlined: true,
                  );
                }),

                const SizedBox(height: 12),

                // Pay and Mint NFT
                _buildActionButton(
                  'Pay for Property & Mint NFT',
                  Icons.token_outlined,
                  Get.theme.colorScheme.primary,
                  () async {
                    if (data.property == null) {
                      Get.showSnackbar(CommonUI.ErrorSnackBar(
                          message: 'Property details unavailable'));
                      return;
                    }

                    try {
                      final prop = data.property!;
                      final propertyModel = PropertyModel(
                        id: prop.id,
                        title: prop.title,
                        description: prop.about,
                        address: prop.address,
                        city: prop.city,
                        price:
                            (prop.firstPrice ?? prop.secondPrice)?.toString(),
                        titleImage:
                            (prop.media != null && prop.media!.isNotEmpty)
                                ? (prop.media!.first.content ??
                                    prop.media!.first.thumbnail)
                                : null,
                      );
                      // final nftProperty =
                      //     NFTPropertyModel.fromPropertyModel(propertyModel);
                      // final result = await NFTMarketplaceService.to
                      //     .completePurchaseAndMint(property: nftProperty);
                      // if (result != null) {
                      //   Get.toNamed('/my-nfts');
                      // }
                    } catch (e) {
                      Get.showSnackbar(
                          CommonUI.ErrorSnackBar(message: e.toString()));
                    }
                  },
                ),

                const SizedBox(height: 12),

                // View/Claim NFT
                _buildActionButton(
                  'View / Claim NFT',
                  Icons.verified_outlined,
                  Get.theme.colorScheme.secondary,
                  () {
                    Get.toNamed('/my-nfts');
                  },
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, IconData icon,
      Color color, bool isCompleted) {
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
                    color: isCompleted
                        ? Get.theme.colorScheme.onSurface
                        : Get.theme.colorScheme.onSurface.withOpacity(0.5),
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
            _buildActionButton(
              'Cancel Request',
              Icons.cancel_outlined,
              Get.theme.colorScheme.error,
              () => controller.refundSheetButtonClick(data, 0),
            ),
          ],
          if (data.tourStatus == 1) ...[
            _buildActionButton(
              'Request Refund',
              Icons.cancel_outlined,
              Get.theme.colorScheme.error,
              () => controller.refundSheetButtonClick(data, 1),
            ),
          ],
          if (data.tourStatus == 2 &&
              data.completionStatus == 'agent_marked') ...[
            Obx(() => _buildActionButton(
                  'Confirm Tour Completion',
                  Icons.check_circle_outline,
                  Get.theme.colorScheme.primary,
                  () => controller.showConfirmCompletionDialog(data),
                  // () => controller.onWaitingSheetButtonClick(data, 2, 'confirm_completion'),
                  isLoading: controller.isRequestLoading.value,
                )),
            const SizedBox(height: 12),
            Obx(() => _buildActionButton(
                  'Open Dispute',
                  Icons.gavel_rounded,
                  Get.theme.colorScheme.error,
                  () => controller.openDispute(data),
                  isOutlined: true,
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
          if (data.tourStatus == 2 && data.completionStatus == 'disputed') ...[
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
              Get.toNamed('/property-details/${data.property?.id ?? -1}',
                  arguments: {
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

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onTap,
      {bool isOutlined = false, bool isLoading = false}) {
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
            side: isOutlined
                ? BorderSide(color: color, width: 1)
                : BorderSide.none,
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

  ({Color color, IconData icon, String title, String message})
      _getStatusInfo() {
    if (data.tourStatus == 2 && data.completionStatus == 'user_confirmed') {
      return (
        color: Colors.blue,
        icon: Icons.task_alt,
        title: 'Tour Completed',
        message:
            'You have confirmed the tour completion and the fund has been released to the agent',
      );
    }

    if (data.tourStatus == 2 && data.completionStatus == 'agent_marked') {
      return (
        color: Colors.blue,
        icon: Icons.task_alt,
        title: 'Awaiting Your Confirmation',
        message:
            'The agent has marked this tour as completed. Please confirm to release the funds. If you do not confirm and no dispute is opened within 24 hours, the funds will be automatically released to the agent.',
      );
    }

    if (data.tourStatus == 2 && data.completionStatus == 'disputed') {
      return (
        color: Colors.grey,
        icon: Icons.task_alt,
        title: 'Dispute Opened',
        message:
            'There is an open dispute, and the funds will be on hold until the dispute is resolved.',
      );
    }

    if (data.tourStatus == 2 && data.completionStatus == 'auto_confirmed') {
      return (
        color: Colors.green,
        icon: Icons.task_alt,
        title: 'Tour Completed',
        message:
            'The tour has been auto-confirmed and finalized as no dispute was raised within the confirmation period.',
      );
    }

    if (data.tourStatus == 7 && data.completionStatus == 'disputed') {
      return (
        color: Colors.grey,
        icon: Icons.task_alt,
        title: 'Dispute Opened',
        message:
            'A dispute has been opened and the funds will be on hold until the dispute is resolved',
      );
    }

    if (data.tourStatus == 7 && data.completionStatus == 'refunded') {
      return (
        color: Colors.blue,
        icon: Icons.task_alt,
        title: 'Tour Request Refunded',
        message:
            'The Tour Request has been Refunded and funds have been transferred to your wallet',
      );
    }

    if (data.tourStatus == 7 && data.completionStatus == 'to_user') {
      return (
        color: const Color(0xFF1abc9c),
        icon: Icons.task_alt,
        title: 'Dispute Resolved',
        message:
            'The dispute has been resolved and the funds have been transferred to your wallet',
      );
    }

    if (data.tourStatus == 2 && data.completionStatus == 'to_user') {
      return (
        color: const Color(0xFF1abc9c),
        icon: Icons.task_alt,
        title: 'Dispute Resolved',
        message:
            'The dispute has been resolved and the funds have been transferred to your wallet',
      );
    }

    if (data.tourStatus == 2 && data.completionStatus == 'to_agent') {
      return (
        color: const Color(0xFF1abc9c),
        icon: Icons.task_alt,
        title: 'Dispute Resolved',
        message:
            'The dispute has been resolved and the funds have been transferred to the agent',
      );
    }

    if (data.tourStatus == 7 && data.completionStatus == 'completed') {
      return (
        color: Colors.green,
        icon: Icons.task_alt,
        title: 'Tour Request Completed',
        message:
            'The Tour Request has been Completed and funds have been transferred to the agent',
      );
    }

    if (data.tourStatus == 7 && data.completionStatus == 'to_agent') {
      return (
        color: const Color(0xFF1abc9c),
        icon: Icons.task_alt,
        title: 'Dispute Resolved',
        message:
            'The dispute has been resolved and the funds have been transferred to the agent',
      );
    }

    if (data.tourStatus == 3) {
      return (
        color: Colors.red,
        icon: Icons.task_alt,
        title: 'Tour Request Cancelled',
        message:
            'The Tour Request has been Cancelled and funds has been transfer to your wallet',
      );
    }

    switch (data.tourStatus) {
      case 0:
        return (
          color: Colors.orange,
          icon: Icons.schedule,
          title: 'Waiting for Agent Response',
          message: 'The property agent will review your request soon',
        );
      case 1:
        return (
          color: Colors.green,
          icon: Icons.check_circle,
          title: 'Tour Confirmed',
          message:
              'Your tour has been confirmed by the agent and now in progress',
        );
      case 4:
        return (
          color: Colors.red,
          icon: Icons.cancel,
          title: 'Request Declined',
          message:
              'Your tour request was declined by the agent and the funds have been transferred to your wallet',
        );

      case 7:
        return (
          color: Colors.blue,
          icon: Icons.task_alt,
          title: 'Request Refunded',
          message:
              'This property tour has been processed for refund and the funds will be returned to your wallet after 24 hours if no dispute is opened',
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
        message: 'Agent marked as completed, waiting for your confirmation',
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

class _ActionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionLabel({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: MyTextStyle.productMedium(
              color: context.theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
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
