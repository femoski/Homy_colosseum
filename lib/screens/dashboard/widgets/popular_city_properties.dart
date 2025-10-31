import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:homy/models/city_model.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/ui.dart';

class PopularCityPropertiesWidget extends GetView<HomeScreenController> {
  const PopularCityPropertiesWidget({Key? key}) : super(key: key);

  static final List<CityModel> cities = [
    CityModel(
      id: "1",
      name: "Uyo Central",
      image: "https://picsum.photos/500/700?random=21",
      propertyCount: 45,
    ),
    CityModel(
      id: "2",
      name: "Ewet Housing",
      image: "https://picsum.photos/500/500?random=22",
      propertyCount: 32,
    ),
    CityModel(
      id: "3",
      name: "Shelter Afrique",
      image: "https://picsum.photos/500/700?random=23",
      propertyCount: 28,
    ),
    CityModel(
      id: "4",
      name: "Osongama Estate",
      image: "https://picsum.photos/500/500?random=24",
      propertyCount: 35,
    ),
    CityModel(
      id: "5",
      name: "Ikot Ekpene Road",
      image: "https://picsum.photos/500/700?random=25",
      propertyCount: 22,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      id: 'popular_city_properties',
      builder: (controller) {
        return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        if(controller.popularCityProperties.isNotEmpty)...[
        TitleHeader(
          onSeeAll: () { 
            Get.toNamed('/all-areas');
           },
          title: "Popular Areas",
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
          child: StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(controller.popularCityProperties.length.clamp(0, 7), (index) {
              final city = controller.popularCityProperties[index];
              final isLarge = (index % 4 == 0 || index % 5 == 0);
              return StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: isLarge ? 2 : 1,
                child: buildCityCard(city, isLarge),
              );
            }),
          ),
        ),
      ],
    ]);});
  }

  Widget buildCityCard(CityModel city, bool isLarge) {
    return GestureDetector(
      onTap: () {
        String areaName = city.name.replaceAll(' ', '-');
        Get.toNamed('/porpular-area/${areaName}');
      },
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