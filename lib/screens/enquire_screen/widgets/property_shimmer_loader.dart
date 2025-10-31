import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class PropertyShimmerLoader extends StatelessWidget {
  const PropertyShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
        );
      },
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