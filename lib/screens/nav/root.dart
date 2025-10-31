import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/chat_screen/chat_screen.dart';
import 'package:homy/screens/dashboard/home.dart';
// import 'package:homy/screens/reels_screen/reels_screen.dart';
import 'package:homy/screens/saved_screen/saved_screen.dart';
import 'package:homy/utils/constants/app_colors.dart';
import 'package:homy/utils/constants/app_icons.dart';
import 'package:homy/utils/ui.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:ui';

import '../profile/profile_screen.dart';
import '../reels_screen/controllers/reel_main_controller.dart';
import '../reels_screen/reels_main_screen.dart';
import 'custom_navbar.dart';

class NavBar extends GetView<NavController> {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Obx(() => _buildBottomBar(controller)),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }

  Widget _buildBottomBar(NavController controller) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).padding.bottom > 0 ? 10 : 10,
      ),
      child: CustomAnimatedBottomBar(
        containerHeight: 60,
        selectedIndex: controller.selectedIndex.value,
        onItemSelected: (index) => controller.selectedIndex.value = index,
        items: [
          BottomNavyBarItem(
            image: Icon(
              HugeIcons.strokeRoundedHome01,
              size: 25,
              color: controller.selectedIndex.value == 0
                  ? MColors.white
                  : MColors.primary,
            ),
            title: 'Home',
          ),
          BottomNavyBarItem(
            image: Icon(
              HugeIcons.strokeRoundedAllBookmark,
              size: 25,
              color: controller.selectedIndex.value == 1
                  ? MColors.white
                  : MColors.primary,
            ),
            title: 'Saved',
          ),
          BottomNavyBarItem(
            image: Icon(
              HugeIcons.strokeRoundedVideoReplay,
              size: 25,
              color: controller.selectedIndex.value == 2
                  ? MColors.white
                  : MColors.primary,
            ),
            title: 'Reels',
          ),
          BottomNavyBarItem(
            image: Icon(
              HugeIcons.strokeRoundedMessage02,
              size: 25,
              color: controller.selectedIndex.value == 3
                  ? MColors.white
                  : MColors.primary,
            ),
            title: 'Chat',
          ),
          BottomNavyBarItem(
            image: Icon(
              HugeIcons.strokeRoundedUserSettings01,
              size: 25,
              color: controller.selectedIndex.value == 4
                  ? MColors.white
                  : MColors.primary,
            ),
            title: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget bottomBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      height: 65,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.background.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Get.theme.shadowColor.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavItem(0, AppIcons.home, 'Home'),
              buildNavItem(1, AppIcons.chat, 'Chat'),
              buildNavItem(3, AppIcons.properties, 'Properties'),
              buildNavItem(4, AppIcons.profile, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavItem(int index, String icon, String title) {
    final isSelected = controller.selectedIndex.value == index;
    return GestureDetector(
      onTap: () => controller.selectedIndex.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isSelected
              ? Get.theme.colorScheme.tertiary.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Ui.getSvg(
              icon,
              color: isSelected
                  ? Get.theme.colorScheme.tertiary
                  : Get.theme.colorScheme.onTertiary,
              height: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Get.theme.colorScheme.tertiary
                    : Get.theme.colorScheme.onTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavController extends GetxController with GetTickerProviderStateMixin {
  final Rx<int> selectedIndex = 0.obs;
  final ReelMainController reelsController = Get.find();
  

  @override
  void onInit() {
    super.onInit();
    loadReels();

  }

loadReels()async {
 await reelsController.fetchVideos(reelsController.forYouVideos);
  // unawaited(reelsController.preCacheVideoThumbs());
}
  // rive.Artboard? artboard;
  bool isAddMenuOpen = false;
  int rotateAnimationDurationMs = 2000;
  bool showSellRentButton = false;
  // late final AnimationController _forSellAnimationController =
  //     AnimationController(
  //         vsync: this,
  //         duration: const Duration(milliseconds: 400),
  //         reverseDuration: const Duration(milliseconds: 400));
  // late final AnimationController _forRentController = AnimationController(
  //     vsync: this,
  //     duration: const Duration(milliseconds: 300),
  //     reverseDuration: const Duration(milliseconds: 300));

  ///END: Animation for sell and rent button
  // List<ReelData> reels = [];

  final List<Widget> screens = [
   const HomeScreen(),
    const SavedScreen(),
    const ReelsMainScreen(),
    // ReelsScreen(),
    // ReelsScreen(
    //     screenType: ScreenTypeIndex.dashBoard,
    //     reels:[],
    //     // reels: MockPropertyData.getDummyReelsByUserId(1), // Initialize with empty list instead of instance member
    //     position: 0),
    const ChatListScreen(),
    const ProfileScreen(),
  ];
}
