import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HomeRichText extends StatelessWidget {
  final String title1;
  final String title2;

  const HomeRichText({super.key, required this.title1, required this.title2});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: RichText(
        text: TextSpan(
          text: title1,
          style: Get.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: context.theme.colorScheme.onSurface,
          ),
          children: <TextSpan>[
            TextSpan(
              text: ' $title2',
              style: Get.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w400,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
