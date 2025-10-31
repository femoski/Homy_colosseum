import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/screens/enquire_screen/controllers/enquire_screen_controller.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/my_text_style.dart';


class EnquireInfoTopBar extends StatelessWidget {
  final EnquireInfoScreenController controller;

  const EnquireInfoTopBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _buildBackButton(),
            _buildUserName(),
            _buildShareButton(),
            const SizedBox(width: 10),
            if (controller.otherUserID.toString() != AuthHelper.getUserId().toString())
               _buildMoreOptionsButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () => Get.back(),
      child: SizedBox(
        height: 38,
        width: 38,
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Get.theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildUserName() {
    return Expanded(
      child: Opacity(
        opacity: controller.opacity,
        child: Text(
          controller.otherUserData?.fullname ?? '',
          style: MyTextStyle.productMedium(
            color: Get.theme.colorScheme.onPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildShareButton() {
    return InkWell(
      onTap: controller.onShareBtnClick,
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.onPrimary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.share_rounded,
          color: Get.theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildMoreOptionsButton(BuildContext context) {
    return PopupMenuButton<int>(
      // initialValue: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.grey[800],
      onSelected: controller.onMoreBtnClick,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem(
          value: 0,
          child: Text(
            'Report',
            style: MyTextStyle.productLight(
              size: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Text(
            controller.isBlock ? 'Unblock' : 'Block',
            style: MyTextStyle.productLight(
              size: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
      child: Container(
        height: 38,
        width: 38,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.onPrimary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          MImages.twoHorizontal,
          color: Get.theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
