import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/property_model.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:homy/screens/dashboard/widgets/property_card_big.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';

class MostLikedPropertiesWidget extends GetView<HomeScreenController> {
  const MostLikedPropertiesWidget({Key? key}) : super(key: key);


  static final List<PropertyModel> mostLikedProperties = [
    PropertyModel(
      id: 13,
      title: "Luxury Penthouse",
      price: "9500",
      category: Categorys(
        id: 3,
        category: "Penthouses",
        image: "assets/icons/penthouse.svg"
      ),
      description: "Premium penthouse with panoramic city views",
      address: "200 Sky View, Uyo",
      properyType: "Sale",
      promoted: true,
      titleImage: "https://picsum.photos/500/300?random=17",
    ),
    PropertyModel(
      id: 14,
      title: "Beachfront Villa",
      price: "8500",
      category: Categorys(
        id: 2,
        category: "Villas",
        image: "assets/icons/villa.svg"
      ),
      description: "Exclusive villa with private beach access",
      address: "10 Beach Road, Uyo",
      properyType: "Sale",
      promoted: true,
      titleImage: "https://picsum.photos/500/300?random=18",
    ),
    PropertyModel(
      id: 15,
      title: "Modern Apartment",
      price: "3200",
      category: Categorys(
        id: 1,
        category: "Apartments",
        image: "assets/svg/apartment.svg"
      ),
      description: "Contemporary apartment with smart features",
      address: "50 Tech Street, Uyo",
      properyType: "Rent",
      promoted: false,
      titleImage: "https://picsum.photos/500/300?random=19",
    ),
    PropertyModel(
      id: 16,
      title: "Garden Villa",
      price: "6800",
      category: Categorys(
        id: 2,
        category: "Villas",
        image: "assets/icons/villa.svg"
      ),
      description: "Spacious villa with landscaped gardens",
      address: "25 Garden Avenue, Uyo",
      properyType: "Sale",
      promoted: true,
      titleImage: "https://picsum.photos/500/300?random=20",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      id: 'mostLikedProperties',
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleHeader(
          onSeeAll: () {
            Get.toNamed('/all-most-liked');
          },
          title: "Most Liked Properties",
        ),
        Padding(
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
        const SizedBox(height: 10),
      ],
    );
      }
    );
  }
} 