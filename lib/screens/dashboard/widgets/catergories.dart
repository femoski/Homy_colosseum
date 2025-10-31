import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/category.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/screens/dashboard/widgets/category_card.dart';
import 'package:homy/screens/dashboard/widgets/header_card.dart';
import 'package:homy/screens/dashboard/widgets/property_card_big.dart';
import 'package:homy/screens/dashboard/widgets/property_gradient_card.dart';
import 'package:homy/services/categories_service.dart';
import 'package:homy/services/location_service.dart';
import 'package:homy/utils/constants/sizes.dart';
import 'package:homy/utils/helpers/design_helper.dart';
import 'package:homy/utils/responsiveSize.dart';
import 'package:homy/utils/constants/routes.dart';
import 'package:homy/utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';

import 'home_rich_text.dart';

class CategoryWidget extends StatefulWidget {
  CategoryWidget({Key? key}) : super(key: key);

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  final locationService = LocationService();
  final categorieservice = Get.find<CategoriesService>();
final categories = [];

  @override
  void initState() {
    super.initState();
    categorieservice.getAllCategories().then((value) {
      setState(() {
        categories.addAll(value);
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        HomeRichText(
          title1: 'What',
          title2: 'Are your looking for?',
        ),
        SizedBox(
          height: 50.rh(context),
          child: ListView.builder(
            padding: const EdgeInsets.only(
              left: AppSizes.sidePadding,
            ),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length.clamp(0, 5) + 1, // +1 for "View All"
            itemBuilder: (context, index) {
              if (index == categories.length.clamp(0, 5)) {
                return buildViewAllCard(context);
              }

                  // if (index == (3 - 1)) {
                  //     return Padding(
                  //       padding: const EdgeInsetsDirectional.only(start: 5.0),
                  //       child: GestureDetector(
                  //         onTap: () {
                  //           Navigator.pushNamed(context, Routes.categories);
                  //         },
                  //         child: Container(
                  //           constraints: BoxConstraints(
                  //             minWidth: 100.rw(context),
                  //           ),
                  //           alignment: Alignment.center,
                  //           decoration: DesignConfig.boxDecorationBorder(
                  //             color: context.theme.colorScheme.onSecondary,
                  //             radius: 10,
                  //             borderWidth: 1.5,
                  //             borderColor: context.theme.colorScheme.outline,
                  //           ),
                  //           child: Padding(
                  //             padding:
                  //                 const EdgeInsets.symmetric(horizontal: 10),
                  //             child: Text(
                  //                 'more'),
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   }

              return buildCategoryCard(
                context,
                categories[index],
                index != 0,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildCategoryCard(
    BuildContext context,
    Category category,
    bool frontSpacing,
  ) {
    return CategoryCard(
      frontSpacing: frontSpacing,
      onTapCategory: (category) {

      Get.toNamed('/Categories/${category.id}/${category.slug}', arguments: {
        'catID': category.id.toString(),
        'catName': category.title,
      });
        // Get.toNamed(
        //   Routes.propertiesList,
        //   arguments: {
        //     'catID': category.id,
        //     'catName': category.category,
        //   },
        // );
      },
      category: category,
    );
  }


  Widget buildNearByProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Obx(() => TitleHeader(
          onSeeAll: () {},
          title: "Near By Properties (${locationService.city} City)",
        ),),
        SizedBox(
          height: 200,
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sidePadding,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: 6, // Fixed count for now
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              PropertyData model = PropertyData(); // Create empty model for now
              return PropertyGradiendCard(
                model: model,
                isFirst: index == 0,
                showEndPadding: false,
              );
            }
          ),
        ),
      ],
    );
  }



  Widget buildMostLikedProperties() {
    
          return GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sidePadding,
            ),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    mainAxisSpacing: 15, crossAxisCount: 2, height: 260),
            itemCount: 4,
            itemBuilder: (context, index) {
              PropertyData property = PropertyData(); // Create a proper PropertyModel instance
              return GestureDetector(
                onTap: () {
                  // HelperUtils.goToNextPage(
                  //     Routes.propertyDetails, context, false,
                  //     args: {
                  //       'propertyData': property,
                  //       'propertiesList': state.properties,
                  //       'fromMyProperty': false,
                  //     });
                },
                child: PropertyCardBig(
                    showEndPadding: false,
                    isFirst: index == 0,
                    // onLikeChange: (type) {
                    //   // if (type == FavoriteType.add) {
                    //   //   context.read<FetchFavoritesCubit>().add(property);
                    //   // } else {
                    //   //   context.read<FetchFavoritesCubit>().remove(property.id);
                    //   // }
                    // },
                    property: property,
                  ),
              );
            },
          );
        }
      
    
  

 

  Widget buildViewAllCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 5.0),
      child: GestureDetector(
        onTap: () =>  Get.toNamed(Routes.categories),
        child: Row(
          children: <Widget>[
            Container(
          constraints: BoxConstraints(
            minWidth: 100.rw(context),
          ),
                       height: 44.rh(context),

          alignment: Alignment.center,
        decoration: DesignConfig.boxDecorationBorder(
                color: context.theme.colorScheme.surface,
                radius: 10,
                borderWidth: 1.5,
                borderColor: context.theme.colorScheme.outline,
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'View All',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: context.theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ]),
    ));
  }
}
