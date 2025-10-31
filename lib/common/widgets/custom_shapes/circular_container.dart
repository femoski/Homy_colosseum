import 'package:flutter/material.dart';
import 'package:homy/utils/constants/app_colors.dart';

class MCircularContainer extends StatelessWidget {
  const MCircularContainer({
    super.key, this.width = 400, this.height = 400, this.padding = 8, this.child, this.bg = MColors.light, this.radius =400, this.margin,
  });

  final double? width;
  final double? height;
  final double padding;
  final EdgeInsets? margin;
  final double radius;
  final Widget? child;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: bg),
    );
  }
}
