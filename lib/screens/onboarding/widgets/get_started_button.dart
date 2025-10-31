import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/onboarding/controller/onboard_controller.dart';
import 'package:homy/utils/constants/device_utility.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../utils/constants/sizes.dart';
 
class GetStartedButton extends GetView<OnBoardController> {
  GetStartedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: MDeviceUtils.getBottomNavigationBarHeight() + 20,
        right: AppSizes.xl,
        child: ElevatedButton(
          onPressed: () => controller.nextPage(),
          child: Row(
            children: [
              Obx(() => Text(controller.currentPage.value == 2
                  ? 'Get Started'
                  : 'Next')),
              SizedBox(width: AppSizes.sxxs),
              Icon(HugeIcons.strokeRoundedArrowRight01)
            ],
          ),
        ));
  }
}
