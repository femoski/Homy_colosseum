import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/repositories/user_repository.dart';

class ResetPasswordController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  final String email = Get.arguments['email'];
  final String code = Get.arguments['code'];
  final String token = Get.arguments['token'];
  RxBool isLoading = false.obs;
  RxBool isPasswordVisible = false.obs;
  RxBool isConfirmPasswordVisible = false.obs;

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      
      final response = await _userRepository.resetPassword({
        'email': email,
        'token': token,
        'password': passwordController.text,
        'password_confirmation': confirmPasswordController.text,
      });

      if (response['status'] == true) {
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: response['message'],
        ));
        Get.offAllNamed('/login');
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