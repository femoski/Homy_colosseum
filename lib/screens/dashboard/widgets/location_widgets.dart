import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/place_model.dart';
import 'package:homy/screens/dashboard/controller/home_screen_controller.dart';
import 'package:homy/services/location_service.dart';
import 'package:hugeicons/hugeicons.dart';


class LocationWidget extends StatelessWidget {
   LocationWidget({super.key});
  final locationService = Get.find<LocationService>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final place = await Get.toNamed('/search-place');
        if (place != null) {
          final placeModel = place as PlaceModel;
          locationService.place.value = placeModel;
          Get.log('place: ${placeModel.toJson()}');
        }
        Get.find<HomeScreenController>().nearByProperties.clear();
        Get.find<HomeScreenController>().popularCityProperties.clear();
        Get.find<HomeScreenController>().currentPopularCityPage = 1;
        Get.find<HomeScreenController>().currentNearbyPage = 1;
        await Get.find<HomeScreenController>().fetchNearByProperties();
        await Get.find<HomeScreenController>().fetchPopularCity();
      },
      child: FittedBox(
        fit: BoxFit.none,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Icon(HugeIcons.strokeRoundedLocation05, size: 30, color: Theme.of(context).colorScheme.tertiary,),
            ),
            const SizedBox(width: 10),
            Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    '${locationService.place.value?.city}, ${locationService.place.value?.state} , ${locationService.place.value?.country}' ?? 'Select Location',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
