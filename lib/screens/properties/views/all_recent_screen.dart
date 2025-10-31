import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/screens/properties/widgets/property_card.dart';
import 'package:homy/utils/constants/sizes.dart';

class AllRecentScreen extends StatelessWidget {
  const AllRecentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      id: 'recentlyAddedProperties',
      init: HomeScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Recently Added'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.back(),
            ),
            actions: [
              // Filter button
              // IconButton(
              //   onPressed: () {
              //     // TODO: Implement filter functionality
              //   },
              //   icon: Container(
              //     padding: const EdgeInsets.all(8),
              //     decoration: BoxDecoration(
              //       color: Get.theme.colorScheme.primary.withOpacity(0.1),
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     child: Icon(
              //       Icons.tune_rounded,
              //       color: Get.theme.colorScheme.primary,
              //     ),
              //   ),
              // ),
              const SizedBox(width: 10),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              controller.recentlyAddedProperties.clear();
              controller.currentRecentPage = 1;
              await controller.fetchRecentlyAddedProperties();
            },
            child: GetBuilder<HomeScreenController>(
              id: 'recentlyAddedProperties',
              builder: (controller) {
                if (controller.isLoadingRecentProperties &&
                    controller.recentlyAddedProperties.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.recentlyAddedProperties.isEmpty) {
                  return Center(
                    child: CommonUI.noDataFound(
                      width: 50,
                      height: 50,
                      title: 'No Recent Properties Found',
                    ),
                  );
                }

                return ListView.builder(
                  controller: controller.recentPropertiesScrollController,
                  padding: const EdgeInsets.all(AppSizes.sidePadding),
                  itemCount: controller.recentlyAddedProperties.length,
                  itemBuilder: (context, index) {
                    final property = controller.recentlyAddedProperties[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PropertyHorizontalCard(
                        property: property,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
