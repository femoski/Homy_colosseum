import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/search_screen/controllers/search_controller.dart';
import 'package:homy/screens/search_screen/widgets/range_selected_card.dart';
import 'package:homy/screens/search_screen/widgets/search_bath_and_bed.dart';
import 'package:homy/screens/search_screen/widgets/search_location.dart';
import 'package:homy/screens/search_screen/widgets/search_property_category.dart';
import 'package:homy/screens/search_screen/widgets/search_tab.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/my_text_style.dart';


class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SearchScreenController());
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Search Properties',
          style: MyTextStyle.productBold(size: 20),
        ),
        actions: [
          // IconButton(
          //   onPressed: () {},
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
          // const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SafeArea(
                top: false,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Property Type Selection
                      Text(
                        'I\'m looking for',
                        style: MyTextStyle.productBold(size: 20),
                      ),
                      const SizedBox(height: 15),
                      SearchPropertyTab(controller: controller),
                      const SizedBox(height: 15),
                      
                      // Location Selection
                      SearchLocationTab(controller: controller),
                      const SizedBox(height: 15),
                      
                      // Property Category
                      SearchPropertyCategory(controller: controller),
                      // const SizedBox(height: 15),
                      
                      // Price Range
                      GetBuilder(
                        id: controller.uPriceRangeID,
                        init: controller,
                        builder: (controller) => RangeSelectedCard(
                          controller: controller,
                          title: 'Budget Range',
                          startingRange: controller.priceFrom,
                          endingRange: controller.priceTo,
                          minPrice: Constant.minPriceRange,
                          maxPrice: Constant.maxPriceRange,
                          onChanged: controller.onPriceRangeChange,
                        ),
                      ),
                      // const SizedBox(height: 15),
                      
                      // Area Range
                      GetBuilder(
                        id: controller.uAreaRangeID,
                        init: controller,
                        builder: (controller) => RangeSelectedCard(
                          controller: controller,
                          title: 'Area Size',
                          textIcon: 'Sqft',
                          startingRange: controller.areaFrom,
                          endingRange: controller.areaTo,
                          minPrice: Constant.minAreaRange,
                          maxPrice: Constant.maxAreaRange,
                          onChanged: controller.onAreaRangeChange,
                        ),
                      ),
                      const SizedBox(height: 25),
                      
                      // Bed & Bath
                      SearchBathAndBed(controller: controller),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom Action Buttons
          SafeArea(
            top: false,
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Get.theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Reset Button
                  TextButton(
                    onPressed: controller.onResetBtnClick,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Get.theme.colorScheme.primary),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: MyTextStyle.productMedium(
                        size: 16,
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // Search Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.onSearchBtnClick(
                        newSearchType: 1,
                        controller: controller,
                        context: context,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Get.theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Search Now',
                        style: MyTextStyle.productBold(
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
