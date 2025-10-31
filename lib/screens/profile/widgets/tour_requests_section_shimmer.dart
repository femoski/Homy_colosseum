import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class TourRequestsSectionShimmer extends StatelessWidget {
  const TourRequestsSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRequestSectionShimmer(context, isFirst: true),
        const SizedBox(height: 24),
        _buildRequestSectionShimmer(context, isFirst: false),
      ],
    );
  }

  Widget _buildRequestSectionShimmer(BuildContext context, {required bool isFirst}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title shimmer
        Shimmer.fromColors(
          baseColor: context.isDarkMode 
              ? Colors.grey[800]! 
              : Colors.grey[300]!,
          highlightColor: context.isDarkMode 
              ? Colors.grey[700]! 
              : Colors.grey[100]!,
          child: Container(
            width: isFirst ? 180 : 200, // Different widths to match different titles
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Cards row
        Row(
          children: [
            Expanded(child: _buildCardShimmer(context)),
            const SizedBox(width: 12),
            Expanded(child: _buildCardShimmer(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildCardShimmer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.theme.colorScheme.outline.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: context.isDarkMode 
            ? Colors.grey[800]! 
            : Colors.grey[300]!,
        highlightColor: context.isDarkMode 
            ? Colors.grey[700]! 
            : Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Value shimmer
            Container(
              width: 60,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            // Label shimmer
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
      ),
    );
  }
} 