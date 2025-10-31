import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/screens/properties/widgets/property_card.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/services/location_service.dart';
import 'package:homy/widgets/property_filter_sheet.dart';

class AllNearbyPropertiesScreen extends StatelessWidget {
  const AllNearbyPropertiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      init: HomeScreenController(),
      initState: (state) {
        final controller = Get.find<HomeScreenController>();
        controller.resetFilters();
        controller.fetchNearByPropertiesAll(refresh: true);
      },
      builder: (controller) {
        final locationService = Get.find<LocationService>();
        return Scaffold(
          appBar: AppBar(
            title: Obx(() => Text(
              'Properties in ${locationService.place.value.city}',
              style: MyTextStyle.productRegular(
                size: 18,
                fontWeight: FontWeight.w600,
              ),
            )),
            actions: [
              // Filter button
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => PropertyFilterSheet(
                      controller: controller,
                    ),
                  );
                  // TODO: Implement filter functionality
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchNearByPropertiesAll(refresh: true);
            },
            child: GetBuilder<HomeScreenController>(
              id: 'allNearByProperties',
              builder: (controller) {
                if (controller.isLoadingNearbyPropertiesAll &&
                    controller.nearByPropertiesAll.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.nearByPropertiesAll.isEmpty) {
                  return Center(
                    child: CommonUI.noDataFound(
                      width: 50,
                      height: 50,
                      title: 'No Nearby Properties Found',
                    ),
                  );
                }

                return ListView.builder(
                  controller: controller.nearbyPropertiesScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.nearByPropertiesAll.length,
                  itemBuilder: (context, index) {
                    final property = controller.nearByPropertiesAll[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PropertyHorizontalCard(
                        property: property,
                        // onTap: () {
                        //   Get.toNamed(
                        //     '/property-details/${property.id}',
                        //     arguments: {'property': property},
                        //   );
                        // },
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
