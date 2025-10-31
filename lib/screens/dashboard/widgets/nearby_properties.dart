import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:homy/screens/dashboard/widgets/property_gradient_card.dart';
import 'package:homy/screens/dashboard/widgets/shimmer/nearby_properties_shimmer.dart';
import 'package:homy/services/location_service.dart';
import 'package:homy/utils/constants/sizes.dart';

class NearbyPropertiesWidget extends GetView<HomeScreenController> {
  NearbyPropertiesWidget({Key? key}) : super(key: key);
  final locationService = Get.find<LocationService>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      id: 'nearByProperties',
      builder: (controller) {
        if (controller.isLoadingNearbyProperties && controller.nearByProperties.isEmpty) {
          return  NearbyPropertiesShimmer();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(locationService.place.value.city != null && controller.nearByProperties.isNotEmpty)...[
            Obx(() => TitleHeader(
              onSeeAll: () => Get.toNamed('/nearby-properties'),
              title: "Near By Properties (${locationService.place.value.city} City)",
            )),
            SizedBox(
              height: 200,
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sidePadding,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.nearByProperties.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return PropertyGradiendCard(
                    model: controller.nearByProperties[index],
                    isFirst: index == 0,
                    showEndPadding: false,
                  );
                }
              ),
            ),
            ],
          ],
        );
      }
    );
  }
} 