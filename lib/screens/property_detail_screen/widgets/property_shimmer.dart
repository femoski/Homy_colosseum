import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/utils/constants/app_colors.dart';
import 'package:homy/utils/constants/app_icons.dart';
import 'package:homy/utils/ui.dart';
import 'package:shimmer/shimmer.dart';

class PropertyDetailShimmer extends StatelessWidget {
  const PropertyDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HeaderShimmer(),
              Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleAndAddressShimmer(),
                    SizedBox(height: 20),
                    FeaturesRowShimmer(),
                    SizedBox(height: 20),
                    PriceTagShimmer(),
                    SizedBox(height: 20),
                    DescriptionShimmer(),
                    SizedBox(height: 20),
                    MapAreaShimmer(),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Back Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(CupertinoIcons.back, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HeaderShimmer extends StatelessWidget {
  const HeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
            width: Get.width,
            color: context.theme.colorScheme.tertiary.withOpacity(0.15),
            height: Get.height * 0.47,
            alignment: Alignment.center,
            child: FittedBox(
                fit: BoxFit.contain,
           
                child: SizedBox(
                    width: 250,
                    height: 250,
                    child: Ui.getSvg(
                      AppIcons.placeHolder2,
                    ))));
    // return Shimmer.fromColors(
    //   baseColor: const Color.fromARGB(255, 202, 202, 202),
    //   highlightColor:const Color.fromARGB(255, 202, 202, 202).withOpacity(0.6),
    //   child: Container(
    //     height: Get.height * 0.4,
    //     color: Colors.white,
    //   ),
    // );
  }
}

class TitleAndAddressShimmer extends StatelessWidget {
  const TitleAndAddressShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ?  MColors.shimmerBaseColor : const Color.fromARGB(255, 202, 202, 202),
      highlightColor:const Color.fromARGB(255, 202, 202, 202),
      enabled: false,
      child: Column(
        
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 25,
            width: Get.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 15,
            width: Get.width * 0.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturesRowShimmer extends StatelessWidget {
  const FeaturesRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ?  MColors.shimmerBaseColor : const Color.fromARGB(255, 202, 202, 202),
      highlightColor: context.isDarkMode ?  MColors.shimmerBaseColor.withOpacity(0.8) : const Color.fromARGB(255, 202, 202, 202).withOpacity(0.8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              height: 30,
              width: Get.width * 0.25,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PriceTagShimmer extends StatelessWidget {
  const PriceTagShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ?  MColors.shimmerBaseColor : const Color.fromARGB(255, 202, 202, 202),
      highlightColor: Colors.transparent,
      enabled: false,
      child: Row(
        children: [
          Container(
            height: 34,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 34,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ],
      ),
    );
  }
}

class DescriptionShimmer extends StatelessWidget {
  const DescriptionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ?  MColors.shimmerBaseColor : const Color.fromARGB(255, 202, 202, 202),
      highlightColor: context.isDarkMode ?  MColors.shimmerBaseColor.withOpacity(0.8) : const Color.fromARGB(255, 202, 202, 202).withOpacity(0.8),
      enabled: false,
      child: Column(
        children: List.generate(
          6,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 15,
              // width: Get.width * (0.8 - (index * 0.1)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MapAreaShimmer extends StatelessWidget {
  const MapAreaShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ?  MColors.shimmerBaseColor : const Color.fromARGB(255, 202, 202, 202),
      highlightColor: context.isDarkMode ?  MColors.shimmerBaseColor.withOpacity(0.8) : const Color.fromARGB(255, 202, 202, 202).withOpacity(0.8),
      period: Duration(milliseconds: 2000),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
