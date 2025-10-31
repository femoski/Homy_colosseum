import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/common/widgets/not_logged_in_screen.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:homy/screens/properties/widgets/property_card.dart';
import 'package:homy/screens/reels_screen/widgets/reel_grid_card_widget.dart';
import 'package:homy/screens/saved_screen/controllers/saved_controller.dart';
import '../../utils/tab_view_custom.dart';
import 'package:homy/screens/saved_screen/widgets/saved_screen_shimmer.dart';

import '../reels_screen/reels_screen.dart';

class SavedScreen extends GetView<SavedPropertyScreenController> {
  const SavedScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // controller.fetchApi();
    return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // backgroundColor: Get.theme.colorScheme.primary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved',
              style: TextStyle(
                // color: Get.theme.colorScheme.onPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.bookmark,
            ),
          ],
        ),
      ),
      body: AuthHelper.isLoggedIn() ? Column(
        children: [
          
          // DashboardTopBar(title: S.of(context).saved),
          GetBuilder<SavedPropertyScreenController>(
            builder: (controller) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                child: Row(
                  children: List.generate(
                    2,
                    (index) {
                      return TabViewCustom(
                        onTap: controller.onTabChanged,
                        index: index,
                        label: index == 0
                            ? 'Property'
                            : 'Reels',
                        selectedTab: controller.selectedTabIndex,
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: GetBuilder(
              init: controller,
              builder: (controller) {
                
                if (controller.selectedTabIndex == 0) {
                  // Property View
                  return controller.isLoading && controller.savedPropertyData.isEmpty
                      ? const SavedScreenShimmer(isPropertyView: true)
                      : controller.savedPropertyData.isEmpty
                          ? CommonUI.noDataFound(width: 80, height: 80,title: 'No Saved Property',)
                          : PropertyList(controller: controller);
                } else {
                  // Reels View
                  return controller.isLoading && controller.reels.isEmpty
                      ? const SavedScreenShimmer(isPropertyView: false)
                      : controller.reels.isEmpty
                          ? CommonUI.noDataFound(width: 60, height: 60)
                          : ReelsList(controller: controller);
                }
              },
            ),
          )
        ],
      ):
      NotLoggedInScreen(callBack: (success) {
        // if (success) {
        //   Get.offAllNamed(RouteHelper.getLoginRoute());
        // }
      }),
    ));
  }
}

class PropertyList extends StatelessWidget {
  final SavedPropertyScreenController controller;

  const PropertyList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(

      controller: controller.scrollController,
      itemCount: controller.savedPropertyData.length,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) {
        // return Container();
        PropertyData data = controller.savedPropertyData[index];
        return InkWell(
          onTap: () {
                                    Get.toNamed('/property-details/${data.id}');

            // Get.toNamed('/property-detail/${data.id}', arguments: {
            //   'propertyId': data.id ?? -1,
            // });
            // NavigateService.push(
            //   Get.context!,
            //   PropertyDetailScreen(propertyId: data.id ?? -1),
            // ).then(
            //   (value) {
            //     controller.savedPropertyData = [];
            //     controller.fetchSavedPropertyApiCall();
            //   },
            // );
          },
          child: PropertyHorizontalCard(property: data),
        );
      },
    );
  }
}

class ReelsList extends StatelessWidget {
  final SavedPropertyScreenController controller;

  const ReelsList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: .5,
        mainAxisExtent: 185,
      ),
      itemCount: controller.reels.length,
      itemBuilder: (BuildContext context, int index) {
        ReelData reelData = controller.reels[index];
        return ReelGridCardWidget(
          isDeleteShow: false,
          onTap: () {
            // Get.toNamed(Routes.reelsScreen, arguments: {
            //   'screenType': ScreenTypeIndex.savedReel,
            //   'hashTag': 'Saved Reels',
            //   'reels': controller.reels,
            //   'position': index,
            //   'userID': 1,
            //   'onUpdateReel': controller.onUpdateReelsList,
            // });
            Get.to(
              () => ReelsScreen(
                screenType: ScreenTypeIndex.savedReel,
                hashTag: 'Saved Reels',
                reels: controller.reels,
                position: index,
                userID: 1,
                onUpdateReel: controller.onUpdateReelsList,
              ),
              preventDuplicates: true,
            )?.then(
              (value) {
                controller.onRemoveSavedList();
              },
            );
          },
          reelData: reelData,
          height: double.infinity,
          width: double.infinity,
        );
      },
    );
  }
}
