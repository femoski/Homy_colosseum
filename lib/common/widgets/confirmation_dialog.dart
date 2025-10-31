import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/my_text_style.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog(
      {super.key,
      required this.title1,
      required this.title2,
      required this.onPositiveTap,
      required this.aspectRatio,
      this.positiveText});

  final String title1;
  final String title2;
  final VoidCallback onPositiveTap;
  final double aspectRatio;
  final String? positiveText;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Spacer(),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Get.width / 8),
                      child: Text(
                        title1,
                        style: MyTextStyle.productBlack(size: 17),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Get.width / 12),
                      child: Text(
                        title2,
                        style: MyTextStyle.productRegular(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Directionality.of(context) == TextDirection.rtl
                                      ? Colors.transparent
                                      : Colors.white,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'No',
                              style: MyTextStyle.productMedium(size: 17, color: Get.theme.colorScheme.primary),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: onPositiveTap,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Directionality.of(context) != TextDirection.rtl
                                      ? Colors.transparent
                                      : Colors.white,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Text(
                              positiveText ?? 'Yes',
                              style: MyTextStyle.productMedium(
                                size: 17,
                                
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
          ),
        ),
      ),
    );
  }
}
