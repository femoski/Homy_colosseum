import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class NFTGridShimmer extends StatelessWidget {
  final int itemCount;

  const NFTGridShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.theme.brightness == Brightness.dark;
    final onSurface = Get.theme.colorScheme.onSurface;
    final surfaceVariant = Get.theme.colorScheme.surfaceVariant;
    // Tuned for contrast in both themes
    final baseColor = isDark
        ? surfaceVariant.withOpacity(0.24)
        : surfaceVariant.withOpacity(0.45);
    final highlightColor = isDark
        ? onSurface.withOpacity(0.08)
        : onSurface.withOpacity(0.08);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: _ShimmerCard(),
        );
      },
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Get.theme.brightness == Brightness.dark;
    final surface = Get.theme.colorScheme.surface;
    final surfaceVariant = Get.theme.colorScheme.surfaceVariant;
    final outline = Get.theme.colorScheme.outline;
    final overlayLineColor = isDark
        ? Colors.white.withOpacity(0.45)
        : Colors.black.withOpacity(0.12);
    final stateChipBg = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.07);
    final verifiedDotBg = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.08);
    final gradientEndOpacity = isDark ? 0.35 : 0.26;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: surface,
        border: Border.all(
          color: outline.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with overlays to mirror CompactNFTPropertyCard
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: surfaceVariant.withOpacity(0.5),
                    ),
                  ),
                  // Top-left state chip shape
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: stateChipBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 42,
                            height: 8,
                            decoration: BoxDecoration(
                              color: surfaceVariant.withOpacity(isDark ? 0.55 : 0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Top-right verified dot
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: verifiedDotBg,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Bottom gradient-like overlay area
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(gradientEndOpacity),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 10,
                            width: double.infinity,
                            margin: const EdgeInsets.only(right: 40),
                            decoration: BoxDecoration(
                              color: overlayLineColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 8,
                            width: double.infinity,
                            margin: const EdgeInsets.only(right: 80),
                            decoration: BoxDecoration(
                              color: overlayLineColor.withOpacity(isDark ? 0.85 : 0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Footer info rows that mirror price/location structure subtly
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: surfaceVariant.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: surfaceVariant.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}


