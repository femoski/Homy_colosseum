import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:homy/utils/constants/app_colors.dart';

class MyPropertiesShimmer extends StatelessWidget {
  const MyPropertiesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 3, // Show 3 shimmer items
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 1.5,
              color: isDark 
                  ? Colors.grey[800]!
                  : Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image shimmer
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: _buildShimmerContainer(
                  context,
                  height: 200,
                  width: double.infinity,
                ),
              ),
              
              // Content shimmer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title shimmer
                    _buildShimmerContainer(
                      context,
                      height: 24,
                      width: Get.width * 0.7,
                    ),
                    const SizedBox(height: 8),
                    
                    // Address shimmer
                    Row(
                      children: [
                        _buildShimmerContainer(
                          context,
                          height: 16,
                          width: 16,
                          shape: BoxShape.circle,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildShimmerContainer(
                            context,
                            height: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Price and button shimmer
                    Row(
                      children: [
                        _buildShimmerContainer(
                          context,
                          height: 24,
                          width: 120,
                        ),
                        const Spacer(),
                        _buildShimmerContainer(
                          context,
                          height: 40,
                          width: 100,
                          borderRadius: 25,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerContainer(
    BuildContext context, {
    required double height,
    double? width,
    double borderRadius = 4,
    BoxShape shape = BoxShape.rectangle,
  }) {
    final isDark = context.isDarkMode;
    
    return Shimmer.fromColors(
      baseColor: isDark 
          ? MColors.shimmerBaseColor 
          : const Color.fromARGB(255, 224, 224, 224),
      highlightColor: isDark 
          ? const Color.fromARGB(255, 60, 60, 60)
          : const Color.fromARGB(255, 245, 245, 245),
      period: const Duration(milliseconds: 1500),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: shape == BoxShape.rectangle 
              ? BorderRadius.circular(borderRadius)
              : null,
          shape: shape,
        ),
      ),
    );
  }
} 