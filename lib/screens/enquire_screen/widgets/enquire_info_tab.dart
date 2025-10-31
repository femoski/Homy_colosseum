import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/enquire_screen/controllers/enquire_screen_controller.dart';
import 'package:homy/utils/my_text_style.dart';

class EnquireInfoTab extends StatelessWidget {
  final int tabIndex;
  final Function(int) onTabTap;

   EnquireInfoTab({super.key, required this.tabIndex, required this.onTabTap});

  final EnquireInfoScreenController controller = Get.find<EnquireInfoScreenController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          if(controller.userData?.role == 'agent')
          _buildTabItem(
            context,
            index: 0,
            text: 'Listings',
            isRightRounded: false,
            isLeftRounded: true,
          ),
          
          _buildTabItem(
            context,
            index: 2,
            text: 'Reels',
            isRightRounded: false,
            isLeftRounded: controller.userData?.role == 'agent' ? false : true,
          ),
          _buildTabItem(
            context,
            index: 1,
            text: 'Details',
            isRightRounded: true,
            isLeftRounded: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context,
      {required int index, required String text, required bool isRightRounded, required bool isLeftRounded}) {
    return Expanded(
      child: InkWell(
        onTap: () => onTabTap(index),
        child: Container(
          height: 38,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tabIndex == index ? Get.theme.colorScheme.primary : Get.theme.colorScheme.onPrimary,
            borderRadius: BorderRadius.horizontal(
              left: isLeftRounded ? const Radius.circular(100) : const Radius.circular(0),
              right: isRightRounded ? const Radius.circular(100) : const Radius.circular(0),
            ),
          ),
          child: Text(
            text,
            style: MyTextStyle.productRegular(size: 15, color: tabIndex == index ? Get.theme.colorScheme.onPrimary : Get.theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
