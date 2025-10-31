 import 'package:flutter/material.dart';
import '../../../utils/constants/sizes.dart';

class MRoundedImage extends StatelessWidget {
  const MRoundedImage({
    super.key,
    this.width,
    this.height,
    this.radius = AppSizes.nm,
    required this.bg,
    this.applyRadius = true,
    this.onPressed,
    required this.imageUrl,
    this.border,
    this.fit = BoxFit.contain,
    this.isNetworkImage = false,
    this.padding,
  });

  final double? width;
  final double? height;
  final String imageUrl;
  final BoxBorder? border;
  final BoxFit fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final double radius;
  final bool applyRadius;
  final Color bg;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: bg,
          border: border,
        ),
        child: ClipRRect(
          borderRadius:
              applyRadius ? BorderRadius.circular(radius) : BorderRadius.zero,
          child: SizedBox(),
      
        ),
      )
    );
  }
}
