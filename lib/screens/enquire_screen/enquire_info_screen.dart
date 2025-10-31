import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/widgets/primary_header.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/screens/enquire_screen/controllers/enquire_screen_controller.dart';
import 'package:homy/screens/enquire_screen/widgets/details_page.dart';
import 'package:homy/screens/enquire_screen/widgets/enquire_info_tab.dart';
import 'package:homy/screens/enquire_screen/widgets/enquire_info_top_bar.dart';
import 'package:homy/screens/enquire_screen/widgets/enquire_profile_card.dart';
import 'package:homy/screens/enquire_screen/widgets/listing_page.dart';
import 'package:homy/screens/enquire_screen/widgets/reels_page.dart';
import 'package:homy/screens/reels_screen/widgets/reel_helper.dart';
import 'package:homy/utils/my_text_style.dart';

class EnquireInfoScreen extends GetView<EnquireInfoScreenController> {
  final String userId;
  final Function(UserData? userData)? onUpdate;
  final Function(ReelUpdateType type, ReelData data)? onUpdateReel;

  const EnquireInfoScreen(
      {super.key, required this.userId, this.onUpdate, this.onUpdateReel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<EnquireInfoScreenController>(
        builder: (_) {
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                controller.updateStickyHeader(scrollNotification.metrics.pixels);
              }
              return true;
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: controller.scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MPrimaryHeader(
                        bgColor: context.theme.colorScheme.primary,
                        child: Column(
                          children: [
                            // Original top bar that will scroll
                            Opacity(
                              opacity: controller.showStickyHeader ? 0 : 1,
                              child: EnquireInfoTopBar(controller: controller),
                            ),
                            EnquireProfileCard(
                              userData: controller.userData,
                              isBlock: controller.isBlock,
                              controller: controller,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      EnquireInfoTab(
                        tabIndex: controller.selectedTabIndex,
                        onTabTap: controller.onTabTap
                      ),
                      const SizedBox(height: 10),
                      controller.isBlock
                        ? Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.errorContainer.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Get.theme.colorScheme.errorContainer.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.block_rounded,
                                  color: Get.theme.colorScheme.error,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'User Blocked',
                                  style: MyTextStyle.productBold(
                                    color: Get.theme.colorScheme.error,
                                    size: 20
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'You have blocked this user. You won\'t see their content or receive messages from them.',
                                  textAlign: TextAlign.center,
                                  style: MyTextStyle.productRegular(
                                    color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => controller.onMoreBtnClick(1),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Get.theme.colorScheme.surface,
                                    foregroundColor: Get.theme.colorScheme.error,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    side: BorderSide(
                                      color: Get.theme.colorScheme.error.withOpacity(0.5),
                                    ),
                                  ),
                                  icon: const Icon(Icons.lock_open_rounded),
                                  label: Text(
                                    'Unblock User',
                                    style: MyTextStyle.productMedium(),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: (controller.selectedTabIndex == 0
                              ? ListingPage()
                              : controller.selectedTabIndex == 1
                                  ? DetailsPage(
                                      userData: controller.otherUserData,
                                      controller: controller)
                                  : ReelsPage()),
                          ),
                    ],
                  ),
                ),

                // Sticky header that appears when scrolled
                if (controller.showStickyHeader)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Material(
                      color: context.theme.colorScheme.primary,
                      elevation: 4,
                      child: SafeArea(
                        bottom: false,
                        child: EnquireInfoTopBar(controller: controller),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
