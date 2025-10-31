import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/constants/app_colors.dart';

class PersonalizedPropertiesShimmer extends StatelessWidget {
  const PersonalizedPropertiesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header shimmer
        TitleHeader(
          onSeeAll: () {},
          title: "Personalized For You",
        ),
        const SizedBox(height: 16),
        // Properties list shimmer
        SizedBox(
          height: 261,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
            itemCount: 6, // Show 6 shimmer items
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: EdgeInsets.only(
                  right: 15,
                  left: index == 0 ? 0 : 0,
                ),
                child: _buildPropertyCardShimmer(context),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCardShimmer(BuildContext context) {
    final isDark = context.isDarkMode;
    final shimmerBaseColor = isDark ? MColors.shimmerBaseColor : const Color.fromARGB(255, 202, 202, 202);
    final shimmerHighlightColor = isDark ? MColors.shimmerBaseColor.withOpacity(0.8) : const Color.fromARGB(255, 202, 202, 202).withOpacity(0.8);

    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: context.theme.colorScheme.surface,
          border: Border.all(
            width: 1.5,
            color: context.theme.colorScheme.outline,
          ),
        ),
        height: 272,
        width: 250,
        child: Stack(
          children: [
            Column(
              children: [
                // Image section shimmer
                SizedBox(
                  height: 147,
                  child: Stack(
                    children: [
                      // Main image placeholder
                      Container(
                        width: double.infinity,
                        height: 147,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      // Property type badge shimmer
                      PositionedDirectional(
                        start: 10,
                        bottom: 10,
                        child: Container(
                          height: 24,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content section shimmer
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      bottom: 5,
                      left: 12,
                      right: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category row shimmer
                        Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              width: 80,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        // Price shimmer
                        Container(
                          width: 100,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Title shimmer
                        Container(
                          width: double.infinity,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        // Location row shimmer
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Share button shimmer
            PositionedDirectional(
              end: 25,
              top: 128,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
