import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/repositories/user_repository.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/services/fcm_service.dart';
import 'package:homy/utils/device_info_utils.dart';

import '../../../models/users/fetch_user.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final Rx<UserData> currentUser = Get.find<AuthService>().user;

  final UserRepository userRepository = UserRepository();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
   
      // Get device information
      final Map<String, dynamic> deviceInfo = await DeviceInfoUtils.getDeviceInfo();
      Get.log('User logged in from device: $deviceInfo');

   currentUser.value =
          await userRepository.signIn(email: email, password: password, deviceType: deviceInfo['device_type']);

      
      if (currentUser.value != null) {
        // Get FCM token and update it on the server
        final fcmService = Get.find<FCMService>();
        if (fcmService.fcmToken.value != null) {
          await fcmService.updateFCMTokenOnServer(fcmService.fcmToken.value!);
        }
        Get.offAllNamed('/root');
      }


      // // Simulate API call
      // await Future.delayed(const Duration(seconds: 2));

      // // TODO: Implement actual authentication logic here

      // Get.offAllNamed('/root');
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));

      // TODO: Handle error
      print('Error signing in: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signInModal({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      // Get device information
      final Map<String, dynamic> deviceInfo = await DeviceInfoUtils.getDeviceInfo();
      Get.log('User logged in from device: $deviceInfo');

      currentUser.value =
          await userRepository.signIn(email: email, password: password, deviceType: deviceInfo['device_type']);
      if (currentUser.value != null) {
        // Get FCM token and update it on the server
        final fcmService = Get.find<FCMService>();
        if (fcmService.fcmToken.value != null) {
          await fcmService.updateFCMTokenOnServer(fcmService.fcmToken.value!);
        }
      }

      isLoading.value = true;
      return true;
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
