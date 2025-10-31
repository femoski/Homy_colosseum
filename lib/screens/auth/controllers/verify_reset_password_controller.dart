import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/repositories/user_repository.dart';

class VerifyResetPasswordController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final TextEditingController codeController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  final String email = Get.arguments['email'] ?? '';
  RxBool isLoading = false.obs;
  RxInt resendTimer = 60.obs;
  RxBool canResendCode = false.obs;

  @override
  void onInit() {
    super.onInit();
    startResendTimer();
  }

  @override
  void onClose() {
    codeController.dispose();
    super.onClose();
  }

  void startResendTimer() {
    canResendCode.value = false;
    resendTimer.value = 60;
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      resendTimer.value--;
      
      if (resendTimer.value <= 0) {
        canResendCode.value = true;
        return false;
      }
      return true;
    });
  }

  Future<void> verifyCode() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      
      final response = await _userRepository.verifyResetCode({
        'email': email,
        'code': codeController.text.trim(),
      });

      if (response['status'] == true) {
        Get.offNamed('/reset-password', arguments: {
          'email': email,
          'code': codeController.text.trim(),
          'token': response['token'],
        });
      }
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: e.toString(),
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendCode() async {
    if (!canResendCode.value) return;

    try {
      isLoading.value = true;
      
      final response = await _userRepository.forgotPassword({
        'email': email,
      });

      if (response['status'] == true) {
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: 'Verification code resent successfully',
        ));
        startResendTimer();
      }
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: e.toString(),
      ));
    } finally {
      isLoading.value = false;
    }
  }
} 