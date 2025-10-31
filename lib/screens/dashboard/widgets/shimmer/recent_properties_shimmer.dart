import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:shimmer/shimmer.dart';

class RecentPropertiesShimmer extends StatelessWidget {
  const RecentPropertiesShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         TitleHeader(
          onSeeAll: null,
          title: "Recently Added",
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.5,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      if (!Get.isDarkMode)
                        BoxShadow(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Image shimmer
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                        ),
                        child: Shimmer.fromColors(
                          baseColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          highlightColor: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                          child: Container(
                            height: 120,
                            width: 120,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Content shimmer
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ShimmerLine(
                              width: Get.width * 0.4,
                              height: 16,
                              context: context,
                            ),
                            const SizedBox(height: 8),
                            ShimmerLine(
                              width: Get.width * 0.6,
                              height: 14,
                              context: context,
                            ),
                            const SizedBox(height: 8),
                            ShimmerLine(
                              width: Get.width * 0.3,
                              height: 14,
                              context: context,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ShimmerLine extends StatelessWidget {
  final double width;
  final double height;
  final BuildContext context;

  const ShimmerLine({
    Key? key,
    required this.width,
    required this.height,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
      highlightColor: Theme.of(context).colorScheme.outline.withOpacity(0.1),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
} 