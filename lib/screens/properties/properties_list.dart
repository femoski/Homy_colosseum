import 'package:flutter/material.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/common/widgets/shimmerLoadingContainer.dart';
import 'package:homy/screens/Widgets/animated_routes/blur_page_route.dart';
import 'package:get/get.dart';
import 'package:homy/screens/properties/controllers/property_list_controller.dart';
import 'package:homy/screens/properties/widgets/property_card.dart';
import 'package:homy/screens/properties/widgets/property_filter_bottom_sheet.dart';
import 'package:homy/utils/responsiveSize.dart';

import '../../widgets/property_filter_sheet.dart';


class PropertiesList extends StatefulWidget {
  const PropertiesList({super.key, this.categoryId, this.categoryName});
  final int? categoryId;
  final String? categoryName;

  @override
  PropertiesListState createState() => PropertiesListState();
  
  static Route route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => PropertiesList(
        categoryId: arguments?['catID'],
        categoryName: arguments?['catName'] ?? '',
      ),
    );
  }
}

class PropertiesListState extends State<PropertiesList> {
  late ScrollController controller;
  final PropertyListController propertyController = Get.put(PropertyListController());

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_loadMore);
    // propertyController.selectedCategoryName.value = widget.categoryName!;
    Future.delayed(Duration.zero, () {
      propertyController.selectedCategoryId.value = widget.categoryId!.toString();
      // propertyController.selectedCategoryName.value = widget.categoryName!;

      setState(() {});
    });

       propertyController.fetchCategoryDetails(widget.categoryId.toString());

  }

  @override
  void dispose() {
    controller.removeListener(_loadMore);
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isEndReached()) {
      if (propertyController.isLoadingMore.value) return;
      Get.log('load more');
      await propertyController.fetchPropertyFromCategory(widget.categoryId!);
    }
  }

  bool _isEndReached() {
    return controller.position.pixels >= controller.position.maxScrollExtent;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // await interstitialAdManager.show();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Obx(() => Text(
            propertyController.selectedCategoryName.value.isEmpty 
              ? widget.categoryName ?? ''
              : propertyController.selectedCategoryName.value
          )),
          actions: [IconButton(
      onPressed: () async {

         showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PropertyFilterSheet(controller: propertyController),


                // builder: (context) => const PropertyFilter(
                //   // initialSortBy: propertyController.selectedFilter,
                //   // onApplyFilters: (filter) {
                //   //                       Get.log('filter: $filter');

                //   //   propertyController.setFilter(filter);
                //   // },
                // ),
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
          ],
        ),
        body: Obx(() {
          if (propertyController.isLoading.value && propertyController.propertyList.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              itemCount: 10,
              itemBuilder: (context, index) => buildPropertiesShimmer(context),
            );
          }

          if (propertyController.error.value != null) {
            return Center(
              child: Text(propertyController.error.value!),
            );
          }

          final properties = propertyController.propertyList;
          if (properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CommonUI.noDataFound(height: 150, width: 150, title: 'No properties found',
                  subTitle: 'Try adjusting your search criteria',
                  ),
                  const SizedBox(height: 16),
                 
                ],
              ),
            );
          }

          return Padding(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), child: ListView.builder(
            controller: controller,
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return PropertyHorizontalCard(property: property);
            },
          ),);
        }),
      ),
    );
  }

  Widget buildPropertiesShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 120.rh(context),
        decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: Theme.of(context).colorScheme.outline),
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Get.isDarkMode ? Colors.transparent : Theme.of(context).colorScheme.outline,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            CustomShimmer(
              height: 120.rh(context),
              width: 100.rw(context),
            ),
            SizedBox(
              width: 10.rw(context),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomShimmer(
                  width: 100.rw(context),
                  height: 10,
                  borderRadius: 7,
                ),
                CustomShimmer(
                  width: 150.rw(context),
                  height: 10,
                  borderRadius: 7,
                ),
                CustomShimmer(
                  width: 120.rw(context),
                  height: 10,
                  borderRadius: 7,
                ),
                CustomShimmer(
                  width: 80.rw(context),
                  height: 10,
                  borderRadius: 7,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget filterOptionsBtn() {
    return IconButton(
      onPressed: () async {

         showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PropertyFilterBottomSheet(
                  onApplyFilters: (filter) {
                    Get.log('filter: $filter');
                    // propertyController.setFilter(filter);
                  },
                ),
              );
        // final result = await Get.toNamed(
        //   Routes.filterScreen,
        //   arguments: {
        //     'showPropertyType': false,
        //     'filter': propertyController.selectedFilter.value,
        //   },
        // );

        // if (result != null) {
        //   propertyController.setFilter(result as FilterApply);
        //   propertyController.fetchPropertyFromCategory(
        //     widget.categoryId!,
        //     filter: result,
        //     showPropertyType: false,
        //   );
        // }
      },
      icon: const Icon(Icons.filter_list_rounded),
    );
  }
}