import 'package:flutter/material.dart'; 
import '../../../utils/constants/sizes.dart';


class MRoundedContainer extends StatelessWidget {
  const MRoundedContainer({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.radius = AppSizes.nm,
    this.child,
    this.showBorder = false,
    this.borderColor = Colors.blue,
    this.bgColor = Colors.white,
    this.showBg = true,
    this.borderWidth,
  });

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Widget? child;
  final bool showBorder;
  final bool showBg;
  final Color bgColor;
  final Color borderColor;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: showBg ? bgColor : Colors.transparent,
        border: showBorder ? Border.all(color: borderColor, width: borderWidth!) : null,
      ),
      child: child,
    );
  }
}
