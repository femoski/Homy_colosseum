import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/common/widgets/not_logged_in_screen.dart';
import 'package:homy/screens/tour_request/controllers/tour_requests_controller.dart';
import 'package:homy/screens/tour_request/views/enhanced_tour_request_user_sheet.dart';
import 'package:homy/screens/tour_request/views/enhanced_tour_request_sheet.dart';
import 'package:homy/screens/tour_request/views/tour_request_card.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/screens/tour_request/widgets/tour_requests_shimmer.dart';

class TourRequestsScreen extends StatelessWidget {
  const TourRequestsScreen({
    super.key, 
    required this.type, 
    required this.selectedTab,
  });

  final int type;
  final int selectedTab;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TourRequestsController>(
      init: TourRequestsController(type, selectedTab),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Get.theme.colorScheme.background,
          appBar: _buildAppBar(),
          body: AuthHelper.isLoggedIn() ? SafeArea(
            child: Column(
              children: [
                _buildTabBar(controller),
                _buildTourList(controller),
              ],
            ),
          ):
          NotLoggedInScreen(callBack: (success) {
            if (success) {
              controller.tourRequestReceivedApiCall();
            }
          }),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      title: Text(
        type == 0 ? 'Tour Requests Received' : 'Tour Requests Submitted',
        style: MyTextStyle.productBold(
          size: 20,
          color: Get.theme.colorScheme.onBackground,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Get.theme.colorScheme.onBackground,
        ),
        onPressed: () {
          final context = Get.context;
          if (context != null) {
            Navigator.of(context).maybePop();
          } else {
            // Fallback if no context available
            Get.back();
          }
        },
      ),

      actions: [
        if(AuthHelper.isLoggedIn())
        IconButton(
          icon: Icon(Icons.gavel_outlined),
          onPressed: () => Get.toNamed('/disputes'),
        ),
      ],
    );
  }

  Widget _buildTabBar(TourRequestsController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _buildTab(
              controller: controller,
              title: 'Waiting',
              index: 0,
              icon: Icons.schedule,
            ),
            _buildTab(
              controller: controller,
              title: 'Confirmed',
              index: 1,
              icon: Icons.check_circle,
            ),
            _buildTab(
              controller: controller,
              title: 'Ended',
              index: 2,
              icon: Icons.flag,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required TourRequestsController controller,
    required String title,
    required int index,
    required IconData icon,
  }) {
    final isSelected = controller.selectedTab == index;
    return Expanded(
      child: _TabItem(
        title: title,
        icon: icon,
        onTap: () => controller.onTypeChange(index),
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildTourList(TourRequestsController controller) {
    return Expanded(
      child: controller.isLoading
          ? const TourRequestsShimmer()
          : controller.tourData.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: controller.scrollController,
                  itemCount: controller.tourData.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final data = controller.tourData[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onLongPress: () => controller.onPropertyCardClick(data, controller),
                        onTap: () => Get.to(() => 
                        type == 0 ? EnhancedTourRequestSheet(data: data, controller: controller) : EnhancedTourRequestUserSheet(data: data, controller: controller)),
                        child: TourRequestCard(data: data),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 80,
            color: Get.theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tour requests yet',
            style: MyTextStyle.productBold(
              size: 18,
              color: Get.theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your tour requests will appear here',
            style: MyTextStyle.productRegular(
              size: 14,
              color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isSelected,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Get.theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Get.theme.colorScheme.onPrimary
                  : Get.theme.colorScheme.onBackground.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: MyTextStyle.productMedium(
                size: 14,
                color: isSelected
                    ? Get.theme.colorScheme.onPrimary
                    : Get.theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
