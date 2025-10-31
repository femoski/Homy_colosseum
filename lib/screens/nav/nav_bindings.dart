import 'package:get/get.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/screens/nav/root.dart';
import 'package:homy/screens/saved_screen/controllers/saved_controller.dart';
import 'package:homy/services/ads_service.dart';
import 'package:homy/services/notifications/shared_notification_service.dart';

import '../../services/reels_service.dart';
import '../reels_screen/controllers/reel_main_controller.dart';
class NavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NavController());
    // Get.lazyPut(() => HomeScreenController());
    Get.put(HomeScreenController());
    // Get.lazyPut(() => ReelsScreenController(screenType: ScreenTypeIndex.dashBoard, position: 0));
    Get.lazyPut(() => SavedPropertyScreenController());
    Get.put(ReelsService(), permanent: true);
    Get.put(ReelMainController(), permanent: true);
      // Initialize SharedNotificationService
    Get.put(SharedNotificationService());

    AdsService.requestConsentInfoUpdate();
    // Get.put(ReelController(), permanent: true);
    // Get.lazyPut(() => ReelsController());
    // Get.lazyPut(() => ProfileController());
  }
}
