import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/widgets/custom_button.dart';
import 'package:homy/services/location_permission_service.dart';

class LocationPermissionPage extends StatelessWidget {
  final Function? onPermissionGranted;

  LocationPermissionPage({Key? key, this.onPermissionGranted})
      : super(key: key);
  RxBool isloading = false.obs;

  @override
  Widget build(BuildContext context) {
    final locationService = Get.find<LocationPermissionService>();
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              Widget content = Column(
                children: [
                  // Icon Section with adaptive size
                  SizedBox(
                    height: screenHeight * 0.2,
                    child: Center(
                      child: Container(
                        width: screenHeight * 0.15,
                        height: screenHeight * 0.15,
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: screenHeight * 0.08,
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  // Text Content Section
                  Container(
                    constraints: BoxConstraints(
                      minHeight: screenHeight * 0.5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Enable Location Services'.tr,
                          style: Get.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Get.theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Homy would like to access your location to:'.tr,
                          textAlign: TextAlign.center,
                          style: Get.textTheme.bodyLarge,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ..._buildFeatureList(),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'We only access your location when using the app'.tr,
                          textAlign: TextAlign.center,
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Get.theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Button Section
              Obx(() =>    CustomButton(
                    isLoading: isloading.value,
                    height: 48,
                    radius: 10,
                    buttonText: 'Continue'.tr,
                    onPressed: () async {
                      final hasPermission =
                          await locationService.checkLocationPermission();
                      if (hasPermission) {
                        isloading.value = true;
                        if (onPermissionGranted != null) {
                          onPermissionGranted!();
                          Get.back();
                        } else {
                          try {
                            await locationService.getCurrentLocation();
                            isloading.value = false;
                            Get.offAllNamed('/root');
                          } catch (e) {
                            isloading.value = false;
                          }
                        }
                      }
                    },
                    fontSize: 16,
                  )),
                  const SizedBox(height: 16),
                ],
              );

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: content,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFeatureList() {
    final features = [
      (Icons.location_searching_rounded, 'Show properties near your current location'.tr),
      (Icons.map_rounded, 'Display accurate distance to properties'.tr),
      (Icons.recommend_rounded, 'Provide personalized property recommendations'.tr),
      (Icons.notifications_rounded, 'Send alerts about new properties in your area'.tr),
      // (Icons.explore_rounded, 'Discover hidden gems in your neighborhood'.tr),
      // (Icons.local_offer_rounded, 'Access location-based special offers and deals'.tr),
      // (Icons.directions_rounded, 'Get easy navigation to property viewings'.tr),
      // (Icons.safety_check_rounded, 'Improve safety by sharing your viewing location'.tr),
    ];

    return features.expand((feature) => [
      _buildFeatureItem(feature.$1, feature.$2),
      const SizedBox(height: 10),
    ]).toList()..removeLast(); // Remove last SizedBox
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Get.theme.colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
