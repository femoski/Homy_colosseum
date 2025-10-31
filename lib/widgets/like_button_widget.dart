import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/property/property_data.dart';

enum FavoriteType { add, remove }

class LikeButtonWidget extends StatefulWidget {
  final PropertyData property;
  final Function(FavoriteType type)? onLikeChanged;
  final Color? color;
  final bool enableLike;

  const LikeButtonWidget({
    super.key,
    required this.property,
    this.onLikeChanged,
    this.color,
    this.enableLike = true,
  });

  @override
  State<LikeButtonWidget> createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Initialize favorite status from property model
    isFavorite = widget.property.isLiked ?? false;
  }

  void _toggleFavorite() {

    if (!AuthHelper.isLoggedIn()) {
      Get.showSnackbar(CommonUI.infoSnackBar(message: 'You are not logged in'));
      return;
    }

    setState(() {
      isFavorite = !isFavorite;
      if (widget.enableLike) {
        widget.onLikeChanged?.call(
          isFavorite ? FavoriteType.add : FavoriteType.remove,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: widget.color ?? context.theme.colorScheme.primary,
      ),
    );
  }
} 