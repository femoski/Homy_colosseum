import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:homy/utils/constants/app_colors.dart';

class TourRequestsShimmer extends StatelessWidget {
  const TourRequestsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar Shimmer
        // Container(
        //   margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        //   decoration: BoxDecoration(
        //     color: Get.theme.colorScheme.surface,
        //     borderRadius: BorderRadius.circular(16),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withOpacity(0.05),
        //         blurRadius: 10,
        //         offset: const Offset(0, 2),
        //       ),
        //     ],
        //   ),
        //   child: Padding(
        //     padding: const EdgeInsets.all(4),
        //     child: Row(
        //       children: List.generate(3, (index) => Expanded(
        //         child: _buildTabShimmer(context),
        //       )),
        //     ),
        //   ),
        // ),
        
        // List Shimmer
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5, // Show 5 shimmer items
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCardShimmer(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabShimmer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: context.isDarkMode 
            ? MColors.shimmerBaseColor 
            : Colors.grey[300]!,
        highlightColor: context.isDarkMode 
            ? MColors.shimmerBaseColor.withOpacity(0.8)
            : Colors.grey[100]!,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 48,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardShimmer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          if (!Get.isDarkMode)
            BoxShadow(
              color: Get.theme.colorScheme.outline.withOpacity(0.1),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 14,
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
              const SizedBox(height: 16),
              // Property details
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 200,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 