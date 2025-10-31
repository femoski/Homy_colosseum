import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/repositories/user_repository.dart';

class ForgotPasswordController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      
      final response = await _userRepository.forgotPassword({
        'email': emailController.text.trim(),
      });

      Get.log('Femmemem ${response['status']}');

      if (response['status'] == true) {
        Get.offNamed('/verify-reset-password', arguments: {
          'email': emailController.text.trim(),
        });
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: 'Reset password link has been sent to your email',
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
} 