import 'package:get/get.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/screens/auth/controllers/auth_controller.dart';
import 'package:homy/screens/location/controllers/location_controller.dart';
import 'package:homy/services/user_blocking_service.dart';
import 'package:homy/utils/constants.dart';

class GeneralBindings extends Bindings {
  
  @override
  void dependencies() {
    // Get.put(NetworkManager());
    // Get.lazyPut(() => OnBoardController());
    Get.lazyPut(() => AuthController());
    // Get.lazyPut(() => ConfigService());
  Get.lazyPut(() => LocationController());
  Get.lazyPut(() => UserBlockingService());
  Get.lazyPut(() => ApiClient(appBaseUrl: Constants.baseUrl));  }


}
