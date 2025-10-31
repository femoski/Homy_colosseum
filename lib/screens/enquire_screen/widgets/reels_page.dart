import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/enquire_screen/controllers/enquire_screen_controller.dart';
import 'package:homy/screens/reels_screen/widgets/reel_grid_card_widget.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../reels_screen/reels_screen.dart';

class ReelsPage extends GetView<EnquireInfoScreenController> {
  const ReelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EnquireInfoScreenController>(
      id: 'reelsPage',
      builder: (controller) {
        return controller.reels.isEmpty
            ? _buildEmptyState()
            : _buildReelsGrid(controller);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Reels Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first reel to share your moments',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelsGrid(EnquireInfoScreenController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: controller.reels.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          // Alternate heights for visual interest
          final height = index.isEven ? 200.0 : 250.0;
          
          return Hero(
            tag: 'reel_${controller.reels[index].id}',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ReelGridCardWidget(
                  onTap: () => _navigateToReelScreen(controller, index),
                  isDeleteShow: _shouldShowDelete(controller, index),
                  reelData: controller.reels[index],
                  width: double.infinity,
                  height: height,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _shouldShowDelete(EnquireInfoScreenController controller, int index) {
    return controller.reels[index].user?.id == controller.authService.user.value.id;
  }

  void _navigateToReelScreen(EnquireInfoScreenController controller, int index) {
    Get.to(
      () => ReelsScreen(
        screenType: ScreenTypeIndex.user,
        reels: controller.reels,
        position: index,
        userID: controller.otherUserData?.id,
        onUpdateReel: controller.onUpdateList,
      ),
      preventDuplicates: true,
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }
}
