import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:homy/utils/constants/sizes.dart';

class FeaturedPropertiesShimmer extends StatelessWidget {
  const FeaturedPropertiesShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         TitleHeader(
          onSeeAll: null,
          title: "Featured Properties",
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            itemCount: 3,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sidePadding,
            ),
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 15),
                child: Shimmer.fromColors(
                  baseColor: context.isDarkMode 
                    ? Colors.grey[800]! 
                    : Colors.grey[300]!,
                  highlightColor: context.isDarkMode 
                    ? Colors.grey[700]! 
                    : Colors.grey[100]!,
                  period: const Duration(milliseconds: 1500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image placeholder
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title placeholder
                      Container(
                        height: 16,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Address placeholder
                      Container(
                        height: 14,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Price and details row
                      Row(
                        children: [
                          // Price placeholder
                          Container(
                            height: 20,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const Spacer(),
                          // Details icon placeholder
                          Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
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