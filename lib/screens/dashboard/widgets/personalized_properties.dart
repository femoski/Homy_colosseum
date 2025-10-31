import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:homy/screens/dashboard/widgets/property_card_big.dart';
import 'package:homy/screens/dashboard/widgets/shimmer/personalized_properties_shimmer.dart';
import 'package:homy/utils/constants/sizes.dart';

import '../controller/home_screen_controller.dart';

class PersonalizedPropertyWidget extends GetView<HomeScreenController> {
  const PersonalizedPropertyWidget({super.key});

  // static final List<PropertyModel> personalizedProperties = [
  //   PropertyModel(
  //     id: 5,
  //     title: "Modern City Apartment",
  //     price: "2800",
  //     category: Categorys(
  //       id: 1,
  //       category: "Apartments",
  //       image: "assets/svg/apartment.svg"
  //     ),
  //     description: "Contemporary living space with city views",
  //     address: "50 Urban Avenue, Uyo",
  //     properyType: "Rent",
  //     promoted: true,
  //     titleImage: "https://picsum.photos/500/300?random=9",
  //   ),
  //   PropertyModel(
  //     id: 6,
  //     title: "Seaside Villa",
  //     price: "7500",
  //     category: Categorys(
  //       id: 2,
  //       category: "Villas",
  //       image: "assets/icons/villa.svg"
  //     ),
  //     description: "Luxurious beachfront property with private access",
  //     address: "15 Coastal Road, Uyo",
  //     properyType: "Sale",
  //     promoted: true,
  //     titleImage: "https://picsum.photos/500/300?random=10",
  //   ),
  //   PropertyModel(
  //     id: 7,
  //     title: "Eco-Friendly Home",
  //     price: "3900",
  //     category: Categorys(
  //       id: 1,
  //       category: "Apartments",
  //       image: "assets/svg/apartment.svg"
  //     ),
  //     description: "Sustainable living with solar power and green spaces",
  //     address: "88 Green Street, Uyo",
  //     properyType: "Rent",
  //     promoted: false,
  //     titleImage: "https://picsum.photos/500/300?random=11",
  //   ),
  //   PropertyModel(
  //     id: 8,
  //     title: "Downtown Penthouse",
  //     price: "8200",
  //     category: Categorys(
  //       id: 3,
  //       category: "Penthouses",
  //       image: "assets/icons/penthouse.svg"
  //     ),
  //     description: "Exclusive top floor living with panoramic views",
  //     address: "120 Sky Tower, Uyo",
  //     properyType: "Sale",
  //     promoted: true,
  //     titleImage: "https://picsum.photos/500/300?random=12",
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      id: 'personalizedProperties',
      builder: (controller) {
    if (controller.isLoadingPersonalizedProperties && controller.personalizedProperties.isEmpty) {
      return const PersonalizedPropertiesShimmer();
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.personalizedProperties.isNotEmpty) ...[
        TitleHeader(
          onSeeAll: () {
            Get.toNamed('/all-personalized-properties');
          },
          title: "Personalized For You",
        ),
        SizedBox(
          height: 261,
          child: ListView.builder(
            itemCount: controller.personalizedProperties.length.clamp(0, 6),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sidePadding,
            ),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final property = controller.personalizedProperties[index];
              return Container(
                width: 200,
                margin: EdgeInsets.only(
                  right: 15,
                  left: index == 0 ? 0 : 0,
                ),
                child: PropertyCardBig(
                  isFirst: index == 0,
                  property: property,
                  showEndPadding: false,
                ),
              );
            },
          ),
        ),
        ],
        ],
      );
    },
    );
  }
} 