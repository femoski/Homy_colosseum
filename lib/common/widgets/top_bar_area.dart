import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/my_text_style.dart';

class TopBarArea extends StatelessWidget {
  final String title;
  final double bottomSize;
  final Widget? child;

  const TopBarArea({super.key, required this.title, this.bottomSize = 0, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Get.theme.colorScheme.surface,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child:  Icon(
                      Icons.arrow_back,
                      size: 25,
                      color: Get.theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    title,
                    style: MyTextStyle.productRegular(size: 24),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: bottomSize,
                  )
                ],
              ),
            ),
            child ?? const SizedBox()
          ],
        ),
      ),
    );
  }
}
