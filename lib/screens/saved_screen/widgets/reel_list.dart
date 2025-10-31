
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:homy/screens/reels_screen/widgets/reel_grid_card_widget.dart';
import 'package:homy/screens/saved_screen/controllers/saved_controller.dart';

class ReelsList extends GetView<SavedPropertyScreenController> {
  // final SavedPropertyScreenController controller;

  // const ReelsList({super.key, required this.controller});

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
            // Get.to(
            //   () => ReelsScreen(
            //     screenType: ScreenTypeIndex.savedReel,
            //     hashTag: 'Saved Reels',
            //     reels: controller.reels,
            //     position: index,
            //     userID: 1,
            //     onUpdateReel: controller.onUpdateReelsList,
            //   ),
            //   preventDuplicates: true,
            // )?.then(
            //   (value) {
            //     controller.onRemoveSavedList();
            //   },
            // );
          },
          reelData: reelData,
          height: double.infinity,
          width: double.infinity,
        );
      },
    );
  }
}
