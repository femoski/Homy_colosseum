import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/common/widgets/terms_dialog.dart';
import 'package:homy/repositories/user_repository.dart';
import 'package:homy/utils/device_info_utils.dart';

class RegistrationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final UserRepository _userRepository = UserRepository();
  
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final referralCodeController = TextEditingController();
  final _storage = GetStorage();
  final _termsAcceptedKey = 'termsAccepted';

  RxBool isLoading = false.obs;
  RxBool isPasswordVisible = false.obs;
  RxBool isConfirmPasswordVisible = false.obs;
  RxBool hasAcceptedTerms = false.obs;
  String deviceId = '';
  Map<String, dynamic> deviceInfo = {};
  
  @override
  void onInit() async {
    super.onInit();
    final referralCode = Get.parameters['referralCode'];
    if (referralCode != null) {
      referralCodeController.text = referralCode;
    }
    // deviceId = await getDeviceId();
    deviceInfo = await DeviceInfoUtils.getDeviceInfo();
    Get.log('deviceId: $deviceId');
    Get.log('deviceInfo: $deviceInfo');
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    referralCodeController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }


Future<String> getDeviceId() async {
  try {
    return '1234567890';
  } catch (e) {
    Get.log('Error getting Device ID: $e');
    return '';
  }
}



  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    if (!hasAcceptedTerms.value) {
       Get.showSnackbar(
        GetSnackBar(
          message: 'You must accept the terms to create an account'.tr,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
      // await showTermsIfNeeded();
      // return;
    }

    try {
      isLoading.value = true;

      final Map<String, dynamic> data = {
        'username': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'password': passwordController.text,
        'referral_code': referralCodeController.text,
        // 'device_id': deviceId,
        'device_info': deviceInfo,
      };

      final response = await _userRepository.register(data);

      if (response['status'] == true) {
        // Navigate to verification page
        if(response['activation_type'] == 'user_email_activate'){
          Get.offNamed('/verify-registration', arguments: {
            'email': emailController.text,
            'phone': phoneController.text,
            'user_id': response['user']['user_id'],
            'activation_type': response['activation_type'],
          });
        }
        else{
          Get.offNamed('/verify-registration', arguments: {
            'email': emailController.text,
            'phone': phoneController.text,
            'user_id': response['user']['user_id'],
            'activation_type': response['activation_type'],
          });
        }
      } else {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: response['message'] ?? 'Registration failed',
        ));
      }
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: e.toString(),
      ));
    } finally {
      isLoading.value = false;
    }
  }


    Future<void> acceptTerms() async {
    await _storage.write(_termsAcceptedKey, true);
    hasAcceptedTerms.value = true;
  }

  // Add this method for signup flow
  Future<bool> showTermsIfNeeded() async {
    if (!hasAcceptedTerms.value) {
      final accepted = await Get.dialog<bool>(
        const TermsDialog(),
        barrierDismissible: false,
      );
      if (accepted == true) {
        await acceptTerms();
        return true;
      }
      return false;
    }
    return true;
  }

} 