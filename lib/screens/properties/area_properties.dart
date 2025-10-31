import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/screens/properties/controllers/area_properties_controller.dart';
import 'package:homy/screens/properties/widgets/property_card.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:homy/widgets/property_filter_sheet.dart';

class AreaPropertiesScreen extends StatelessWidget {
  final String? areaName;
  
  const AreaPropertiesScreen({
    Key? key, 
     this.areaName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AreaPropertiesController>(
      init: AreaPropertiesController(areaName!),
      id: 'area_properties',
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Properties in $areaName',
              style: MyTextStyle.productRegular(
                size: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              // Filter button
              IconButton(
                onPressed: () {
                  _showFilterBottomSheet(context, controller);
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
          body: Obx(() {
            if (controller.isLoading.value && controller.properties.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error.value != null) {
              return Center(
                child: Text(controller.error.value!),
              );
            }

            if (controller.properties.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonUI.noDataFound(height: 150, width: 150),
                    const SizedBox(height: 16),
                    Text(
                      'No properties found in this area',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search criteria',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshProperties,
              child: ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.properties.length + (controller.hasMoreData.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.properties.length) {
                    return controller.isLoadingMore.value
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : const SizedBox();
                  }

                  final PropertyData property = controller.properties[index];
                  return PropertyHorizontalCard(
                    property: property,
                  );
                },
              ),
            );
          }),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context, AreaPropertiesController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PropertyFilterSheet(controller: controller),
    );
  }
}
