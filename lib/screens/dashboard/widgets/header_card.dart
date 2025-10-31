import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/extentions/extentions.dart';



class TitleHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  bool? enableShowAll;
  TitleHeader(
      {super.key, required this.title, this.onSeeAll, this.enableShowAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 20.0, bottom: 16, start: AppSizes.sidePadding, end: AppSizes.sidePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title)
                .bold(weight: FontWeight.w600)
                .color(context.theme.colorScheme.onSurface)
                .size(context.theme.textTheme.titleMedium!.fontSize!)
                .setMaxLines(lines: 1),
          ),
          if (enableShowAll ?? true)
            GestureDetector(
              onTap: () {
                onSeeAll?.call();
                },
                child: const Text('See All')
                    .size(context.theme.textTheme.titleSmall!.fontSize!)
                    // .color(context.theme.colorScheme.onSurface.withOpacity(0.6))
                    // .bold(weight: FontWeight.w400),
              )
        ],
      ),
    );
  }
}
