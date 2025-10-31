import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:homy/utils/constants/sizes.dart';

import '../../../../services/location_service.dart';

class NearbyPropertiesShimmer extends StatelessWidget {
   NearbyPropertiesShimmer({Key? key}) : super(key: key);
  final locationService = Get.find<LocationService>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header shimmer

         Obx(() => TitleHeader(
              onSeeAll: () {},
              title: "Near By Properties (${locationService.place.value.city} City)",
            )),

        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
        //   child: Shimmer.fromColors(
        //     baseColor: context.isDarkMode 
        //       ? Colors.grey[800]! 
        //       : Colors.grey[300]!,
        //     highlightColor: context.isDarkMode 
        //       ? Colors.grey[700]! 
        //       : Colors.grey[100]!,
        //     child: 
        //     Container(
        //       width: 250,
        //       height: 24,
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.circular(4),
        //       ),
        //     ),
        //   ),
        // ),
        const SizedBox(height: 16),
        // Properties list shimmer
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsetsDirectional.only(
                  start: index == 0 ? 0 : 5.0,
                  end: 5.0,
                ),
                child: Container(
                  width: 300,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Shimmer.fromColors(
                    baseColor: context.isDarkMode 
                      ? Colors.grey[800]! 
                      : Colors.grey[300]!,
                    highlightColor: context.isDarkMode 
                      ? Colors.grey[700]! 
                      : Colors.grey[100]!,
                    child: Stack(
                      children: [
                        // Image placeholder
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.white,
                        ),
                        // Gradient overlay simulation
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.white.withOpacity(0.8),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Content placeholders
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
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
                      ],
                    ),
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