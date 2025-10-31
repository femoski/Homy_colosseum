import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/my_text_style.dart';


class UserImageCustom extends StatelessWidget {
  final String image;
  final String name;
  final double widthHeight;
  final Color? borderColor;

  const UserImageCustom(
      {super.key, required this.image, required this.name, required this.widthHeight, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widthHeight,
      width: widthHeight,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? Colors.transparent,
        ),
      ),
      child: ClipOval(
        child: image.isEmpty
            ? ErrorTextImageUser(widthHeight: widthHeight, name: name)
            : CachedNetworkImage(
                imageUrl: image,
                cacheKey: image,
                fit: BoxFit.cover,
                errorWidget: (context, error, stackTrace) {
                  return ErrorTextImageUser(widthHeight: widthHeight, name: name);
                },
              ),
      ),
    );
  }
}

class ErrorTextImageUser extends StatelessWidget {
  final double widthHeight;
  final String name;

  const ErrorTextImageUser({super.key, required this.widthHeight, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthHeight,
      height: widthHeight,
      padding: name.isEmpty ? const EdgeInsets.all(15) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: name.isEmpty ? Get.theme.colorScheme.primary : Get.theme.colorScheme.primary.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: name.isEmpty
          ? Image.asset(MImages.logo)
          : Text(
              (name.isEmpty ? 'h' : name[0]).toUpperCase(),
              style: MyTextStyle.productBlack(color: Get.theme.colorScheme.outline, size: widthHeight / 1.8),
            ),
    );
  }
}
