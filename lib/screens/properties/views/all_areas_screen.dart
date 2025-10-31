import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:homy/models/city_model.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/ui.dart';

class AllAreasScreen extends GetView<HomeScreenController> {
  const AllAreasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Popular Areas'.tr),
      ),
        body: GetBuilder<HomeScreenController>(
          // init: HomeScreenController(),
          id: 'popular_city_properties',
          builder: (controller) {
            if (controller.isLoading && controller.popularCityProperties.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

          return RefreshIndicator(
            onRefresh: controller.refreshAreas,
            child: SingleChildScrollView(
              controller: controller.popularCityScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.sidePadding),
                    child: StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: List.generate(
                        controller.popularCityProperties.length,
                        (index) {
                          final city = controller.popularCityProperties[index];
                          final isLarge = index % 3 == 0;
                          return StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: isLarge ? 1.5 : 1,
                            child: _buildAreaCard(city, isLarge),
                          );
                        },
                      ),
                    ),
                  ),
                  if (controller.isLoading && controller.popularCityProperties.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAreaCard(CityModel city, bool isLarge) {
    return GestureDetector(
      onTap: () => controller.onAreaTap(city.name),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Ui.getImage(
              city.image,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    city.name,
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${city.propertyCount} Properties",
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 