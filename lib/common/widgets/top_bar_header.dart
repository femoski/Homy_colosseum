import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/my_text_style.dart';

class TopBarHeader extends StatelessWidget {
  final String title;
  final bool isBtnVisible;
  final VoidCallback? onTap;
  final Widget? widget;

  const TopBarHeader({super.key, required this.title, this.isBtnVisible = false, this.onTap, this.widget});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Text(
              title.toUpperCase(),
              style: Get.theme.textTheme.titleLarge?.copyWith(color: Get.theme.colorScheme.onPrimary,fontSize: 16),
            ),
            const Spacer(),
            isBtnVisible
                ? InkWell(
                    onTap: onTap,
                    child: widget ??
                         Icon(
                          Icons.settings_rounded,
                          color: Get.theme.colorScheme.onPrimary,
                          size: 30,
                        ),
                  )
                : const SizedBox(
                    height: 22,
                  )
          ],
        ),
      ),
    );
  }
}
