import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/repositories/user_repository.dart';
import 'dart:async';

import '../../../services/config_service.dart';

class VerificationController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  
  final emailPinController = TextEditingController();
  final phonePinController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  
  String email = 'support@homy.ng';
  String user_id = '1';
  Map<String, dynamic> user_data = {};
  String phone = '08138888888';
  
  RxBool isLoading = false.obs;
  RxBool isEmailVerified = false.obs;
  RxBool isPhoneVerified = false.obs;
  RxBool canResendEmailCode = false.obs;
  RxBool canResendPhoneCode = false.obs;
  RxInt emailResendTimer = 60.obs;
  RxInt phoneResendTimer = 60.obs;
  RxBool isChangingPhone = false.obs;
  RxBool isChangingEmail = false.obs;
  Timer? _emailTimer;
  Timer? _phoneTimer;
  RxInt currentStep = 0.obs;
  bool isWhatsappSmsEnabled = false;

  final RxBool isEmailPinValid = false.obs;
  final RxBool isPhonePinValid = false.obs;


  @override
  void onReady() {
    super.onReady();
    if(Get.arguments['activation_type'] == 'user_email_activate'){
      currentStep.value = 0;
    }
    if(Get.arguments['activation_type'] == 'user_phone_activate'){
      currentStep.value = 1;
    }
  }

  @override
  void onClose() {
    emailPinController.dispose();
    phonePinController.dispose();
    phoneController.dispose();
    emailController.dispose();
    _emailTimer?.cancel();
    _phoneTimer?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();

        user_data = Get.arguments['user_data'] ?? {};
        Get.log('user_data: ${user_data}');

        if(user_data['email_verified'] == 1){
          isEmailVerified.value = true;
        }
        if(user_data['phone_verified'] == 1){
          isPhoneVerified.value = true;
        }
        email = Get.arguments['email'] ?? '';
        user_id = Get.arguments['user_id']?.toString() ?? '';
        if(user_data['phone_number'] != null){
          phone = user_data['phone_number'];
        }
        else{
          phone = Get.arguments['phone'] ?? '';
        }


      if(Get.arguments['activation_type'] == 'user_email_activate'){
       
        phoneController.text = phone;
        emailController.text = email;
        startEmailResendTimer();
      } else {
         email = Get.arguments['email'] ?? '';
        user_id = Get.arguments['user_id']?.toString() ?? '';
        phoneController.text = phone;
        emailController.text = email;
        Get.log('user_id: $user_id'); 
        startPhoneResendTimer();
      }
    
    getConfig();

    emailPinController.addListener(() {
      isEmailPinValid.value = emailPinController.text.length == 6;
    });
    phonePinController.addListener(() {
      isPhonePinValid.value = phonePinController.text.length == 6;
    });
  }

  Future<void> getConfig() async {
    final configService = await ConfigService.getConfig();
    
    isWhatsappSmsEnabled = configService.config.value?.isWhatsappSmsEnabled ?? false;
    Get.log('isWhatsappSmsEnabled: $isWhatsappSmsEnabled');
    // if(configService.config.value?.isEmailVerificationEnabled == true){
    //   currentStep.value = 0;
    // }
    if(configService.config.value?.isPhoneVerificationEnabled == false){
      isPhoneVerified.value = true;
    }

  }

  void startEmailResendTimer() {
    canResendEmailCode.value = false;
    emailResendTimer.value = 60;
    _emailTimer?.cancel();
    _emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (emailResendTimer.value > 0) {
        emailResendTimer.value--;
      } else {
        canResendEmailCode.value = true;
        timer.cancel();
      }
    });
  }

  void startPhoneResendTimer() {
    canResendPhoneCode.value = false;
    phoneResendTimer.value = 60;
    _phoneTimer?.cancel();
    _phoneTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (phoneResendTimer.value > 0) {
        phoneResendTimer.value--;
      } else {
        canResendPhoneCode.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> verifyEmail() async {
    if (emailPinController.text.length != 6) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Please enter the email verification code',
      ));
      return;
    }

    try {
      isLoading.value = true;

      final response = await _userRepository.verifyCode({
        'type': 'email',
        'user_id': user_id,
        'identifier': email,
        'code': emailPinController.text,
      });

      if (response['status'] == true) {
        isEmailVerified.value = true;
        startPhoneResendTimer();
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: 'Email verified successfully!',
        ));
        // currentStep.value++;
      } else {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: response['message'] ?? 'Email verification failed',
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

  Future<void> verifyPhone() async {
    if (phonePinController.text.length != 6) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Please enter the phone verification code',
      ));
      return;
    }

    try {
      isLoading.value = true;

        final response = await _userRepository.verifyCode({
          'type': 'phone',
          'user_id': user_id,
          'identifier': phone,
          'code': phonePinController.text,
      });

      if (response['status'] == true) {
        isPhoneVerified.value = true;
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: 'Phone number verified successfully!',
        ));
        // completeVerification();
      } else {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: response['message'] ?? 'Phone verification failed',
        ));
      }
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'An error occurred. Please try again.',
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendEmailCode() async {
    try {
      isLoading.value = true;

      final response = await _userRepository.resendEmailCode({
        // 'email': email,
        'user_id': user_id,
      });

   Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: response['message'] ?? 'Failed to send email code',
        ));
           startEmailResendTimer();

      // if (response['status'] == true) {
      //   Get.showSnackbar(CommonUI.SuccessSnackBar(
      //     message: 'Email verification code sent successfully',
      //   ));
      // } else {
      //   Get.showSnackbar(CommonUI.SuccessSnackBar(
      //     message: response['message'] ?? 'Failed to send email code',
      //   ));
      //      startEmailResendTimer();

      // }
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'An error occurred. Please try again.',
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePhoneNumber() async {
    if (phoneController.text.isEmpty) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Please enter a phone number',
      ));
      return;
    }

    try {
      isLoading.value = true;

      final response = await _userRepository.updatePhone({
        'phone': phoneController.text,
      });

      if (response['status'] == true) {
        phone = phoneController.text;
        isChangingPhone.value = false;
        startPhoneResendTimer();
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: 'Verification code sent to new phone number',
        ));
      } else {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: response['message'] ?? 'Failed to update phone number',
        ));
      }
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'An error occurred. Please try again.',
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendPhoneCode({bool isWhatsApp = false}) async {
    try {
      isLoading.value = true;

      final response = await _userRepository.resendPhoneCode({
        'user_id': user_id,
        'phone': phone,
        'via_whatsapp': isWhatsApp,
      });

      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: response['message'] ?? 'Failed to send phone code',
      ));
      startPhoneResendTimer();

    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'An error occurred. Please try again.',
      ));
    } finally {
      isLoading.value = false;
    }
  }

  void nextStep() {
    if (currentStep.value == 0) {
      if (!isEmailVerified.value) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Please verify your email first',
        ));
        return;
      }
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void completeVerification() {
    Get.offAllNamed('/login');
    Get.showSnackbar(CommonUI.SuccessSnackBar(
      message: 'Account verified successfully! Please login.',
    ));
  }

  Future<void> updateEmail() async {
    if (emailController.text.isEmpty) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Please enter an email',
      ));
      return;
    }
    try {
      isLoading.value = true;
      // Here you would call an API to update the email if needed
      email = emailController.text;
      isChangingEmail.value = false;
      await resendEmailCode();
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: 'Verification code sent to new email',
      ));
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'An error occurred. Please try again.',
      ));
    } finally {
      isLoading.value = false;
    }
  }

  void cancelEmailEdit() {
    emailController.text = email;
    isChangingEmail.value = false;
  }

  Future<void> updatePhone() async {
    await updatePhoneNumber();
  }

  void cancelPhoneEdit() {
    phoneController.text = phone;
    isChangingPhone.value = false;
  }

  Future<bool> validateAndUpdateEmail(String newEmail) async {
    if (newEmail == email)
    {
      Get.back();
      return true;
    }

    try {
      isLoading.value = true;
      // Check if email exists (replace with actual API call if available)
      final response = await _userRepository.checkEmailExists({ 'email': newEmail ,'user_id': user_id});
      Get.log('responsesdasda: ${response}');


      if(response['exists'] == true){
      email = newEmail;
      emailController.text = newEmail;
      Get.back();
      // await resendEmailCode();
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: response['message'],
      ));
      return true;
      } 


      if (response['exists'] == false) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: response['message'],
        ));
        return false;
      }
     
      return true;
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'An error occurred. Please try again.',
      ));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> validateAndUpdatePhone(String newPhone) async {
    if (newPhone == phone) 
    {
      Get.back();
      return true;
    }
    try {
      isLoading.value = true;
      // Check if phone exists (replace with actual API call if available)
      final response = await _userRepository.checkPhoneExists({ 'phone': newPhone ,'user_id': user_id});
      Get.log('responsesdasda: ${response}');


      if(response['exists'] == true){
      phone = newPhone;
      phoneController.text = newPhone;
      Get.back();
      // await resendPhoneCode();
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: response['message'],
      ));
      return true;
      }
     
      else if (response['exists'] == false) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: response['message'],
        ));
        return false;
      }
  
      return true;
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'An error occurred. Please try again.',
      ));
      return false;
    } finally {
      isLoading.value = false;
    }
  }
} 