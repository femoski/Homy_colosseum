import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/screens/property_detail_screen/controllers/property_detail_controller.dart';
import 'package:homy/screens/property_detail_screen/widgets/property_header.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/my_text_style.dart';

class Utilities extends GetView<PropertyDetailScreenController> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PropertyHeading(title: 'Nearby Amenities'),
          const SizedBox(height: 12),
          UtilitiesGrids(),
        ],
      ),
    );
  }
}

class UtilitiesGrids extends GetView<PropertyDetailScreenController> {
  @override
  Widget build(BuildContext context) {
    final utilities = [
      UtilitiesCustom(MImages.hospitalIcon, 'Hospital', controller.propertyData?.farFromHospital ?? '0'),
      UtilitiesCustom(MImages.schoolIcon, 'School', controller.propertyData?.farFromSchool ?? '0'),
      UtilitiesCustom(MImages.gymIcon, 'Gym', controller.propertyData?.farFromGym ?? '0'),
      UtilitiesCustom(MImages.marketIcon, 'Market', controller.propertyData?.farFromMarket ?? '0'),
      UtilitiesCustom(MImages.gasolineIcon, 'Gasoline', controller.propertyData?.farFromGasoline ?? '0'),
      UtilitiesCustom(MImages.airportIcon, 'Airport', controller.propertyData?.farFromAirport ?? '0'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        primary: false,
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: utilities.length,
        itemBuilder: (context, index) {
          final data = utilities[index];
          return _buildUtilityCard(context, data);
        },
      ),
    );
  }

  Widget _buildUtilityCard(BuildContext context, UtilitiesCustom data) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    data.image,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.name,
                        style: MyTextStyle.productMedium(
                          size: 13,
                          color: context.theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.directions_walk,
                            size: 12,
                            color: context.theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${data.duration} km',
                            style: MyTextStyle.productLight(
                              size: 11,
                              color: context.theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
