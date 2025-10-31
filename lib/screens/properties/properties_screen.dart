import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/category.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/screens/properties/controllers/properties_controller.dart';
import 'package:homy/screens/properties/widgets/property_card.dart';
import 'package:homy/screens/properties/widgets/property_filter_bottom_sheet.dart';
import 'package:homy/screens/properties/widgets/property_grid_card.dart';
import 'package:homy/screens/properties/widgets/property_grid_shimmer.dart';
import 'package:homy/utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import 'package:homy/screens/properties/widgets/my_properties_shimmer.dart';

import '../../utils/my_text_style.dart';

class PropertyTypeScreen extends StatelessWidget {
  final Category? type;
  final int screenType;
  final Map<String, dynamic> map;

  const PropertyTypeScreen({
    super.key,
    required this.type,
    required this.map,
    required this.screenType,
  });

  @override
  Widget build(BuildContext context) {
    Get.delete<PropertiesController>();
    final controller = Get.put(PropertiesController(type, map, screenType));
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Properties List',
          style: MyTextStyle.productBold(size: 20),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.toggleViewMode(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() => Icon(
                controller.isGridView.value ? Icons.list : Icons.grid_view,
                color: Get.theme.colorScheme.primary,
              )),
            ),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PropertyFilterBottomSheet(
                  onApplyFilters: (filter) {
                    Get.log('filter: $filter');
                    controller.setFilter(filter);
                  },
                ),
              );
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
      body: GetBuilder<PropertiesController>(
        init: controller,
        builder: (controller) {
          // Show shimmer while loading
          if (controller.isLoading && controller.propertyData.isEmpty) {
            return Obx(() => controller.isGridView.value
              ? GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    mainAxisSpacing: 15,
                    crossAxisCount: 2,
                    height: 260,
                  ),
                  itemCount: 6, // Show 6 shimmer items
                  itemBuilder: (_, __) => const PropertyGridShimmer(),
                )
              : const MyPropertiesShimmer()
            );
          }

          // Show empty state
          if (controller.propertyData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonUI.noDataFound(height: 150, width: 150, title: 'No properties found',
                  subTitle: 'Try adjusting your search criteria',
                  ),
                  const SizedBox(height: 16),
                  // Text(
                  //   'No properties found',
                  //   style: Theme.of(context).textTheme.titleMedium,
                  // ),
                  // const SizedBox(height: 8),
                 
                ],
              ),
            );
          }

          // Show actual content
          return RefreshIndicator(
            onRefresh: () async {
              // TODO: Implement refresh functionality
            },
            child: Obx(() => controller.isGridView.value 
              ? GridView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    mainAxisSpacing: 15, crossAxisCount: 2, height: 260),
                  itemCount: controller.propertyData.length,
                  itemBuilder: (context, index) {
                    PropertyData data = controller.propertyData[index];
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed('/property-details/${data.id}');
                      },
                      child:  PropertyGridCard(
                        isFirst: index == 0,
                        property: data,
                      ),
                    );
                  },
                )
              : ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: controller.propertyData.length,
                  itemBuilder: (context, index) {
                    PropertyData data = controller.propertyData[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed('/property-details/${data.id}');
                        },
                        child: PropertyHorizontalCard(
                          property: data,
                        ),
                      ),
                    );
                  },
                ),
          ));
        },
      ),
    );
  }
}
