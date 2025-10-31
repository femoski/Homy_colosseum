import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/onboarding/controller/onboard_controller.dart';
import 'package:homy/utils/constants/app_colors.dart';
import 'package:homy/utils/constants/device_utility.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

 import '../../../utils/constants/sizes.dart';
 import '../../../utils/helpers/helper_function.dart';

class BottomNavDot extends GetView<OnBoardController> {
  BottomNavDot({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = MHelperFunctions.isDarkMode(context);

    return Positioned(
        bottom: MDeviceUtils.getBottomNavigationBarHeight() + 30,
        left: AppSizes.xl,
        child: SmoothPageIndicator(
          controller:controller.pageController,
          onDotClicked: controller.dotNavigationClick,
          count: 3,
          effect: ExpandingDotsEffect(
              activeDotColor: dark ? MColors.light : MColors.primary,
              dotHeight: 8),
        ));
  }
}
