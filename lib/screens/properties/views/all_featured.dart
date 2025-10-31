import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import '../../dashboard/controller/home_screen_controller.dart';
import '../../dashboard/widgets/property_card_big.dart';

class AllFeaturedProperties extends StatelessWidget {
  AllFeaturedProperties({Key? key}) : super(key: key);

  final HomeScreenController controller = Get.find<HomeScreenController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Featured Properties'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<HomeScreenController>(
        builder: (controller) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //   crossAxisCount: 2,
            //   childAspectRatio: 0.72,
            //   crossAxisSpacing: 10,
            //   mainAxisSpacing: 10,
            //   mainAxisExtent: 272,
            // ),
             gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    mainAxisSpacing: 15, crossAxisCount: 2, height: 260),
            itemCount: controller.mostLikedProperties.length.clamp(0, 4),
            itemBuilder: (context, index) {
              final property = controller.mostLikedProperties[index];
              return GestureDetector(
                onTap: () {
                  // HelperUtils.goToNextPage(
                  //   Routes.propertyDetails,
                  //   context,
                  //   false,
                  //   args: {
                  //     'propertyData': property,
                  //     'propertiesList': mostLikedProperties,
                  //     'fromMyProperty': false,
                  //   },
                  // );
                },
                child: Container(
                  height: 272,
                  child: PropertyCardBig(
                    showEndPadding: false,
                  isFirst: index == 0,
                    property: property,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
