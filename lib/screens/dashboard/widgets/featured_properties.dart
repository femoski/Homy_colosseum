import 'package:flutter/material.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:homy/screens/dashboard/widgets/property_card_big.dart';
import 'package:homy/screens/dashboard/widgets/shimmer/featured_properties_shimmer.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:get/get.dart';

class FeaturedPropertiesWidget extends GetView<HomeScreenController> {
  const FeaturedPropertiesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      id: 'featuredProperties',
      builder: (controller) {
        if (controller.isLoadingFeaturedProperties) {
          return const FeaturedPropertiesShimmer();
        }

        if (controller.featuredProperties.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleHeader(
              onSeeAll: () {
                Get.toNamed('/all-featured');
                // Navigate to all featured properties
              },
              title: "Featured Properties",
            ),
            SizedBox(
              height: 260,
              child: ListView.builder(
                itemCount: controller.featuredProperties.length.clamp(0, 6),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sidePadding,
                ),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final property = controller.featuredProperties[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 15),
                    child: PropertyCardBig(
                      property: property,
                      showEndPadding: false,
                      isFirst: index == 0,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
} 