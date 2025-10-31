import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ChatListShimmer extends StatelessWidget {
  const ChatListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Avatar shimmer
              Shimmer.fromColors(
                baseColor: context.theme.colorScheme.outline.withOpacity(0.2),
                highlightColor: context.theme.colorScheme.outline.withOpacity(0.1),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.theme.colorScheme.outline.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Name shimmer
                        Shimmer.fromColors(
                          baseColor: context.theme.colorScheme.outline.withOpacity(0.2),
                          highlightColor: context.theme.colorScheme.outline.withOpacity(0.1),
                          child: Container(
                            width: 120,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        // Time shimmer
                        Shimmer.fromColors(
                          baseColor: context.theme.colorScheme.outline.withOpacity(0.2),
                          highlightColor: context.theme.colorScheme.outline.withOpacity(0.1),
                          child: Container(
                            width: 50,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Message shimmer
                    Shimmer.fromColors(
                      baseColor: context.theme.colorScheme.outline.withOpacity(0.2),
                      highlightColor: context.theme.colorScheme.outline.withOpacity(0.1),
                      child: Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
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
} 