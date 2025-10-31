import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/search_screen/controllers/search_controller.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/my_text_style.dart';

class SearchLocationTab extends StatelessWidget {
  final SearchScreenController controller;

  const SearchLocationTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      id: controller.uLocationID,
      init: controller,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where would you like to find property?',
              style: MyTextStyle.productBold(size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Search by city or enable location for nearby properties',
              style: MyTextStyle.productRegular(
                size: 14,
                color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            
            // Search Box
            Container(
              height: 55,
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: controller.showLocationError 
                      ? Get.theme.colorScheme.error
                      : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Get.theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: controller.onLocationCardClick,
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: controller.showLocationError
                              ? Get.theme.colorScheme.error
                              : Get.theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.selectedLocationName.isNotEmpty
                                ? controller.selectedLocationName
                                : 'Search city or enable location',
                            style: MyTextStyle.productRegular(
                              size: 16,
                              color: controller.selectedLocationName.isNotEmpty
                                  ? Get.theme.colorScheme.onBackground
                                  : Get.theme.colorScheme.onBackground.withOpacity(0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Error message
            if (controller.showLocationError) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Please select a location',
                  style: MyTextStyle.productRegular(
                    size: 12,
                    color: Get.theme.colorScheme.error,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Location Options
            Row(
              children: [
                Expanded(
                  child: _buildOptionCard(
                    icon: Icons.location_city_rounded,
                    title: 'Search by City',
                    isSelected: controller.selectLocationIndex == 0,
                    onTap: () => controller.onLocationTabChange(0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOptionCard(
                    icon: Icons.my_location_rounded,
                    title: 'Nearby Properties',
                    isSelected: controller.selectLocationIndex == 1,
                    onTap: () => controller.onLocationTabChange(1),
                  ),
                ),
              ],
            ),

            // Radius Selector (only visible when "Nearby Properties" is selected)
            if (controller.selectLocationIndex == 1) ...[
              const SizedBox(height: 24),
              Text(
                'Search Radius',
                style: MyTextStyle.productMedium(size: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Get.theme.shadowColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${controller.radiusValue.toInt()}',
                          style: MyTextStyle.productBold(size: 24),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'km',
                          style: MyTextStyle.productMedium(
                            size: 16,
                            color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                      ),
                      child: Slider(
                        min: Constant.minRadius,
                        max: Constant.maxRadius,
                        onChanged: controller.onRadiusChange,
                        value: controller.radiusValue,
                        activeColor: Get.theme.colorScheme.primary,
                        inactiveColor: Get.theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Get.theme.colorScheme.primary.withOpacity(0.1)
                : Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? Get.theme.colorScheme.primary
                  : Get.theme.colorScheme.outline,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Get.theme.colorScheme.primary
                    : Get.theme.colorScheme.onBackground.withOpacity(0.6),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: MyTextStyle.productMedium(
                  size: 14,
                  color: isSelected
                      ? Get.theme.colorScheme.primary
                      : Get.theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
