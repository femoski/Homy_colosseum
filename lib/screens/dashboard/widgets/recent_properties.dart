import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/property_model.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:homy/screens/dashboard/widgets/property_horizontal_card.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/screens/dashboard/widgets/shimmer/recent_properties_shimmer.dart';

class RecentPropertiesSectionWidget extends GetView<HomeScreenController> {
  const RecentPropertiesSectionWidget({Key? key}) : super(key: key);

  static final List<PropertyModel> recentProperties = [
    PropertyModel(
      id: 9,
      title: "Studio Apartment",
      price: "1200",
      category: Categorys(
        id: 1,
        category: "Apartments",
        image: "assets/svg/apartment.svg"
      ),
      description: "Cozy studio perfect for singles or couples",
      address: "25 Student Lane, Uyo",
      properyType: "Rent",
      promoted: false,
      titleImage: "https://picsum.photos/500/300?random=13",
    ),
    PropertyModel(
      id: 10,
      title: "Family Villa",
      price: "4500",
      category: Categorys(
        id: 2,
        category: "Villas",
        image: "assets/icons/villa.svg"
      ),
      description: "Spacious 4-bedroom villa with garden",
      address: "75 Family Road, Uyo",
      properyType: "Sale",
      promoted: true,
      titleImage: "https://picsum.photos/500/300?random=14",
    ),
    PropertyModel(
      id: 11,
      title: "Office Space",
      price: "2800",
      category: Categorys(
        id: 1,
        category: "Commercial",
        image: "assets/svg/apartment.svg"
      ),
      description: "Modern office space in business district",
      address: "100 Business Avenue, Uyo",
      properyType: "Rent",
      promoted: false,
      titleImage: "https://picsum.photos/500/300?random=15",
    ),
    PropertyModel(
      id: 12,
      title: "Luxury Condo",
      price: "3900",
      category: Categorys(
        id: 3,
        category: "Penthouses",
        image: "assets/icons/penthouse.svg"
      ),
      description: "High-end condo with premium amenities",
      address: "150 Elite Street, Uyo",
      properyType: "Sale",
      promoted: true,
      titleImage: "https://picsum.photos/500/300?random=16",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      id: 'recentlyAddedProperties',
      builder: (controller) {
        if (controller.isLoadingRecentProperties) {
          return const RecentPropertiesShimmer();
        }

        if (controller.recentlyAddedProperties.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleHeader(
              onSeeAll: () => Get.toNamed('/all-recent'),
              title: "Recently Added",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.recentlyAddedProperties.length.clamp(0, 4),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final property = controller.recentlyAddedProperties[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: PropertyHorizontalCard(
                      property: property,
                      additionalImageWidth: 10,                    
                      // showLikeButton: property.isLiked??false,
                        onLikeChange: (type) {
                          controller.onLikeChange(type.name, property.id??0);
                        },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
    );
  }
} 