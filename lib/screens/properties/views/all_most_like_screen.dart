import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/screens/properties/widgets/property_card.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/widgets/property_filter_sheet.dart';


class AllMostLikedScreen extends StatelessWidget {
  const AllMostLikedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      init: HomeScreenController(),
      initState: (state) {
        final controller = Get.find<HomeScreenController>();
        controller.resetFilters();
        controller.fetchMostLikedPropertiesAll(refresh: true);
      },
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Most Liked Properties'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            actions: [
              // Filter button
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
        builder: (context) => PropertyFilterSheet(controller: controller),
                  
                    
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
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchMostLikedPropertiesAll(refresh: true);
            },
            child: GetBuilder<HomeScreenController>(
              id: 'mostLikedPropertiesAll',
              builder: (controller) {
                if (controller.isLoadingMostLikePropertiesAll && controller.mostLikedPropertiesAll.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.mostLikedPropertiesAll.isEmpty) {
                  return Center(
                    child: CommonUI.noDataFound(
                      width: 50,
                      height: 50,
                      title: 'No Most Liked Properties Found',
                    ),
                  );
                }

                return ListView.builder(
                  controller: controller.mostlikePropertiesScrollController,
                  padding: const EdgeInsets.all(AppSizes.sidePadding),
                  itemCount: controller.mostLikedPropertiesAll.length,
                  itemBuilder: (context, index) {
                    final property = controller.mostLikedPropertiesAll[index];
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
