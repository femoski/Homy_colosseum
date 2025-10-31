import 'package:flutter/material.dart';
import 'package:get/get.dart';
 import 'package:homy/screens/onboarding/controller/onboard_controller.dart';
import 'package:homy/utils/constants/device_utility.dart';

import '../../../utils/constants/sizes.dart';

class TopSkipButton extends GetView<OnBoardController> {
  const TopSkipButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: MDeviceUtils.getAppBarHeight(),
        right: AppSizes.sm,
        child: TextButton(
            onPressed: () => controller.skipPage(),
            child: Obx(() => Text(
                controller.currentPage.value == 2 ? ' ' : 'Skip',
                style: Theme.of(context).textTheme.labelLarge))),);
  }
}
