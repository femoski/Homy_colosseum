import 'package:flutter/material.dart';
import 'package:get/get.dart';
  import 'package:homy/utils/constants/app_colors.dart';

class CustomAnimatedBottomBar extends StatelessWidget {
  const CustomAnimatedBottomBar({
    super.key,
    this.selectedIndex = 0,
    this.showElevation = true,
    this.animationDuration = const Duration(milliseconds: 250),
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    required this.containerHeight,
    required this.items,
    required this.onItemSelected,
    this.curve = Curves.linear,
  });

  final int selectedIndex;
  final bool showElevation;
  final Duration animationDuration;
  final List<BottomNavyBarItem> items;
  final ValueChanged<int> onItemSelected;
  final MainAxisAlignment mainAxisAlignment;
  final double containerHeight;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          if (showElevation)
            const BoxShadow(
              color: Colors.transparent,
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: SafeArea(
        top: false, 
        bottom: false,
        child: Container(
          width: double.infinity,
          height: containerHeight,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: items.map((item) {
              var index = items.indexOf(item);
              return GestureDetector(
                onTap: () => onItemSelected(index),
                child: ItemWidget(
                  item: item,
                  isSelected: index == selectedIndex,
                  backgroundColor: MColors.white,
                  animationDuration: animationDuration,
                  curve: curve,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final bool isSelected;
  final BottomNavyBarItem item;
  final Color backgroundColor;
  final Duration animationDuration;
  final Curve curve;

  const ItemWidget({
    super.key,
    required this.isSelected,
    required this.item,
    required this.backgroundColor,
    required this.animationDuration,
    this.curve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      selected: isSelected,
      child: AnimatedContainer(
        width: isSelected ? 100 : 50,
        height: double.maxFinite,
        duration: animationDuration,
        curve: curve,
        decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30), color: isSelected ? MColors.primary : Colors.transparent),

            // borderRadius: BorderRadius.circular(30), color: isSelected ? MColors.primary : MColors.premium),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            width: isSelected ? 100 : 50,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Spacer(flex: 1),
                item.image,
                if (isSelected)
                  Text(
                    '  ${item.title}',
                    style: Get.textTheme.bodyMedium!.copyWith(fontSize: 16,fontWeight: FontWeight.w500,color: MColors.white),
                  ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavyBarItem {
  BottomNavyBarItem({
    required this.image,
    required this.title,
    this.textAlign,
  });

  final Widget image;
  final String title;
  final TextAlign? textAlign;
}
