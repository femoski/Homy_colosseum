import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/screens/properties/controllers/add_edit_property_controller.dart';
import 'package:homy/screens/properties/widgets/modern_text_field.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/my_text_style.dart';


class LocationPage extends StatelessWidget {
  final AddEditPropertyScreenController controller;

  const LocationPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModernTextField(
                controller: controller.propertyAddressController,
                labelText: 'Property Address',
                hintText: 'Enter property address',
                prefixIcon: Icons.location_on_outlined,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.streetAddress,
                errorText: controller.showErrorsLocation && controller.propertyAddressController.text.isEmpty ? 'Please enter property address' : null,
              ),
              const SizedBox(height: 24),
              
              Text(
                'Property Location',
                style: MyTextStyle.productRegular(
                  size: 15,
                  color: Get.theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: controller.onFetchLocation,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: controller.latLng == null 
                            ? Get.theme.colorScheme.surface 
                            : Get.theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.showErrorsLocation && controller.latLng == null
                              ? Colors.red
                              : Get.theme.colorScheme.primary.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Get.theme.colorScheme.primary.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            controller.latLng == null 
                                ? Icons.my_location_outlined
                                : Icons.check_circle_outline,
                            color: Get.theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.latLng == null 
                                ? 'Click to Fetch Location' 
                                : 'Location Fetched',
                            style: Get.theme.textTheme.bodyMedium!.copyWith(
                              fontSize: 15,
                              color: Get.theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (controller.showErrorsLocation && controller.latLng == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Please fetch property location',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Get.theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Get.theme.colorScheme.primary.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Utilities',
                          style: MyTextStyle.productRegular(
                            size: 17,
                            fontWeight: FontWeight.w600,
                            color: controller.selectPropertyCategoryIndex == 0 
                                ? Get.theme.colorScheme.onSurface
                                : Get.theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        Text(
                          'Distance in Time',
                          style: MyTextStyle.productRegular(
                            size: 15,
                            color: controller.selectPropertyCategoryIndex == 0 
                                ? Get.theme.colorScheme.primary
                                : Get.theme.colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildUtilityItem(
                      controller: controller.hospitalController,
                      title: 'Hospital',
                      icon: MImages.hospitalIcon,
                      isEnabled: controller.selectPropertyCategoryIndex == 0,
                    ),
                    _buildUtilityItem(
                      controller: controller.schoolController,
                      title: 'School',
                      icon: MImages.schoolIcon,
                      isEnabled: controller.selectPropertyCategoryIndex == 0,
                    ),
                    _buildUtilityItem(
                      controller: controller.mallController,
                      title: 'Shopping Mall',
                      icon: MImages.marketIcon,
                      isEnabled: controller.selectPropertyCategoryIndex == 0,
                    ),
                    _buildUtilityItem(
                      controller: controller.restaurantController,
                      title: 'Gym',
                      icon: MImages.gymIcon,
                      isEnabled: controller.selectPropertyCategoryIndex == 0,
                    ),
                    _buildUtilityItem(
                      controller: controller.busStopController,
                      title: 'Bus Stop',
                      icon: MImages.airportIcon,
                      isEnabled: controller.selectPropertyCategoryIndex == 0,
                    ),
                  ],
                ),
              ),                    const SizedBox(height: 50),

            ],
          ),
        );
      },
    );
  }

  Widget _buildUtilityItem({
    required TextEditingController controller,
    required String title,
    required String icon,
    required bool isEnabled,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.3,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                icon,
                height: 24,
                width: 24,
                color: isEnabled ? Get.theme.colorScheme.primary : Get.theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: Get.theme.textTheme.bodyMedium!.copyWith(
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernTextField(
                controller: controller,
                hintText: '0 min',
                textAlign: TextAlign.center,
                isEnabled: isEnabled,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
