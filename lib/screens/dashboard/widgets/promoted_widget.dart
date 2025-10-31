import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/extentions/extentions.dart';


enum PromoteCardType { text, icon }

class PromotedCard extends StatelessWidget {
  final PromoteCardType type;
  final Color? color;
  const PromotedCard({super.key, required this.type, this.color});

  @override
  Widget build(BuildContext context) {
    if (type == PromoteCardType.icon) {
      return Container(
        // width: 64,
        // height: 24,
        decoration: BoxDecoration(
            color: color ?? context.theme.colorScheme.tertiary,
            borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Center(
            child: Text('Featured')
                .color(
                  context.theme.colorScheme.onPrimary,
                )
                .bold()
                .size(context.theme.textTheme.bodySmall!.fontSize!),
          ),
        ),
      );
    }

    return Container(
      width: 64,
      height: 24,
      decoration: BoxDecoration(
          color: context.theme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(4)),
      child: Center(
        child: Text('Featured')
            .color(
              context.theme.colorScheme.onPrimary,
            )
            .bold()
            .size(context.theme.textTheme.bodySmall!.fontSize!),
      ),
    );
  }
}
