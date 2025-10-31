import 'dart:ui';

import 'package:flutter/material.dart';

class BlurBGIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;
  final bool isVisible;

  const BlurBGIcon(
      {super.key,
      required this.icon,
      required this.onTap,
      required this.color,
      required this.iconColor,
      this.isVisible = true});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 38,
          width: 38,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 38,
                width: 38,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
