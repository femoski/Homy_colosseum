import 'package:flutter/material.dart';

import '../../utils/constants/app_colors.dart';
import 'custom_shapes/circular_container.dart';

class MPrimaryHeader extends StatelessWidget {
  const MPrimaryHeader({super.key, required this.child,
    required this.bgColor,
  });

  final Widget child;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        // bottomLeft: Radius.circular(16),
        // bottomRight: Radius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor
        ),
        padding: EdgeInsets.all(0),
        child: Stack(
          children: [
            //Background Custom Shapes (Circular Container)
            Positioned(
                top: -150,
                right: -180,
                child: MCircularContainer(bg: MColors.light.withOpacity(0.1))),
            Positioned(
                top: 10,
                right: -280,
                child: MCircularContainer(bg: MColors.light.withOpacity(0.1))),
            child,
          ],
        ),
      ),
    );
  }
}
