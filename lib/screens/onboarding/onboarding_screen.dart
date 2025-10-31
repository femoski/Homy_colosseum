import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/onboarding/controller/onboard_controller.dart';
import 'package:homy/screens/onboarding/widgets/onboard.dart';
import 'package:homy/utils/constants/text_strings.dart';

class OnBoardingScreen extends GetView<OnBoardController> {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Page View
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnBoardingPage(
                lottie: controller.onBoardingOneData,
                title: MTexts.onboard1,
                subtitle: MTexts.onboardSub1,
              ),
              OnBoardingPage(
                lottie: controller.onBoardingTwoData,
                title: MTexts.onboard2,
                subtitle: MTexts.onboardSub2,
              ),
              OnBoardingPage(
                lottie: controller.onBoardingThreeData,
                title: MTexts.onboard3,
                subtitle: MTexts.onboardSub3,
              ),
            ],
          ),

          // Skip Button with Fade Animation
          Positioned(
            top: 50,
            right: 20,
            child: Obx(
              () => AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: controller.currentPage.value < 2 ? 1.0 : 0.0,
                child: TextButton(
                  onPressed: controller.skipPage,
                  child: Text(
                    'Skip',
                    style: Get.textTheme.bodyLarge?.copyWith(
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Navigation
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dot Indicators
                Row(
                  children: List.generate(
                    3,
                    (index) => Obx(
                      () => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: controller.currentPage.value == index ? 25 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: controller.currentPage.value == index
                              ? Get.theme.colorScheme.primary
                              : Get.theme.colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Next/Get Started Button with Animation
                Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: controller.currentPage.value == 2 ? 150 : 60,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.all(8),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: controller.currentPage.value == 2
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: Get.textTheme.bodyLarge?.copyWith(
                                      color: Get.theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Get.theme.colorScheme.onPrimary,
                                  ),
                                ],
                              )
                            : Icon(
                                Icons.arrow_forward,
                                color: Get.theme.colorScheme.onPrimary,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
