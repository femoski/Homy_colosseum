import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:homy/screens/dashboard/widgets/property_horizontal_card.dart';
import 'package:homy/utils/constants/sizes.dart';

class AllPropertiesListWidget extends GetView<HomeScreenController> {
  const AllPropertiesListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      id: 'allProperties',
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleHeader(
              title: "All Properties",
              enableShowAll: false,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sidePadding,
              ),
              itemCount: controller.allProperties.length + 1,
              itemBuilder: (context, index) {
                if (index == controller.allProperties.length) {
                  return controller.isLoadingAllProperties
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : const SizedBox(height: 16);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PropertyHorizontalCard(
                    property: controller.allProperties[index],
                    onLikeChange: (type) {
                      controller.onLikeChange(type.name, controller.allProperties[index].id??0);
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
