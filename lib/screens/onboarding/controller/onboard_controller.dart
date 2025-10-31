import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/lotti/lotti_editor.dart';

class OnBoardController extends GetxController {
  static OnBoardController get instance => Get.find();

  // Variables
  final pageController = PageController();
  final currentPage = 0.obs;

  // Update Current Index when Page Changes
  void updatePageIndicator(index) => currentPage.value = index;

  // Jump to specific dot selected page
  void dotNavigationClick(index) {
    currentPage.value = index;
    pageController.jumpToPage(index);
  }

  // Update Current Index & jump to next page
  void nextPage() {
    if (currentPage.value == 2) {
      Get.offAllNamed('/location-permission');
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Skip the onBoarding
  void skipPage() {
    Get.offAllNamed('/location-permission');
  }


  // Get Lottie Files
  final onBoardingOneData = LottieEditor.onBoardingOne;
  final onBoardingTwoData = LottieEditor.onBoardingTwo;
  final onBoardingThreeData = LottieEditor.onBoardingThree;

  @override
  void onInit() {
    
    super.onInit();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
