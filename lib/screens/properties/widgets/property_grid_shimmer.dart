import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:homy/utils/constants/app_colors.dart';

class PropertyGridShimmer extends StatelessWidget {
  const PropertyGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 1.5,
          color: context.isDarkMode 
              ? Colors.grey[800]!
              : Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
        boxShadow: [
          if (!context.isDarkMode)
            BoxShadow(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: context.isDarkMode 
            ? MColors.shimmerBaseColor 
            : Colors.grey[300]!,
        highlightColor: context.isDarkMode 
            ? MColors.shimmerBaseColor.withOpacity(0.8)
            : Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image shimmer
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title shimmer
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Location shimmer
                  Container(
                    height: 14,
                    width: Get.width * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price shimmer
                  Container(
                    height: 18,
                    width: Get.width * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 