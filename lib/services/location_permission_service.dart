import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homy/repositories/location_repository.dart';
import 'package:homy/services/location_service.dart';
import 'package:location/location.dart' as loc;
import 'package:homy/screens/location/location_permission_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationPermissionService extends GetxService {
  final location = !kIsWeb ? loc.Location() : null;
  final isLocationEnabled = false.obs;
  final hasPermission = false.obs;
  bool isModalVisible = false;

  // Add new properties to store location coordinates
  final Rx<double?> latitude = Rx<double?>(null);
  final Rx<double?> longitude = Rx<double?>(null);
  final isLocationLoading = false.obs;
final LocationRepository locationRepository = LocationRepository();
  // @override
  // void onInit() {
  //   super.onInit();
  //   checkLocationPermission();
  //   // Monitor location service status only on mobile
  //   if (!kIsWeb) {
  //     location!.enableBackgroundMode(enable: true);
  //     location!.onLocationChanged.listen((loc.LocationData locationData) async {
  //       bool serviceEnabled = await location!.serviceEnabled();
  //       _updateLocationStatus(serviceEnabled);
        
  //       // Update coordinates when location changes
  //       if (serviceEnabled && hasPermission.value) {
  //         latitude.value = locationData.latitude;
  //         longitude.value = locationData.longitude;
  //       }
  //     });
  //   }
  // }

  void _updateLocationStatus(bool enabled) {
    isLocationEnabled.value = enabled;
    if (!enabled && !isModalVisible) {
      showLocationDisabledModal();
    } else if (enabled && isModalVisible) {
      Get.back(); // Close the modal
      isModalVisible = false;
    }
  }

  void showLocationDisabledModal() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:  Icon(
                Icons.location_on,
                color: Get.theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Enable Location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To provide you with the best experience, we need access to your location.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              if (!isLocationEnabled.value)
                _buildStepItem(
                  index: 1,
                  title: 'Enable Location Services',
                  subtitle: 'Turn on location services in your device settings',
                  icon: Icons.settings_suggest,
                ),
              if (!isLocationEnabled.value)
                const SizedBox(height: 16),
              if (!hasPermission.value)
                _buildStepItem(
                  index: !isLocationEnabled.value ? 2 : 1,
                  title: 'Allow Location Access',
                  subtitle: 'Grant Homy permission to access your location',
                  icon: Icons.security,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Not Now',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8, right: 8),
            child: ElevatedButton(
              onPressed: () async {
                Get.back();
                if (!isLocationEnabled.value) {
                  if (kIsWeb) {
                    showLocationDisabledDialog();
                  } else {
                    await location!.requestService();
                  }
                }
                if (!hasPermission.value) {
                  await checkLocationPermission();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text(
                'Enable Location',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildStepItem({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                icon,
                color: Get.theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step $index: $title',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showLocationPermissionPage({Function? onPermissionGranted}) {
    if (!isModalVisible) {
      isModalVisible = true;
      Get.to(
        () => LocationPermissionPage(onPermissionGranted: onPermissionGranted),
        transition: Transition.downToUp,
      )?.then((_) {
        isModalVisible = false;
      });
    }
  }

  Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    if (kIsWeb) {
      // For web, we only need to check if geolocation is supported
      try {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      } catch (e) {
        // If geolocation is not supported or blocked by browser
        isLocationEnabled.value = false;
        hasPermission.value = false;
        showLocationDisabledDialog();
        return false;
      }
    } else {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }

    if (!serviceEnabled) {
      isLocationEnabled.value = false;
      if (!kIsWeb) {
        showLocationDisabledModal();
      } else {
        showLocationDisabledDialog();
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        hasPermission.value = false;
        showPermissionDeniedDialog();
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      hasPermission.value = false;
      showPermissionDeniedForeverDialog();
      return false;
    }

    isLocationEnabled.value = true;
    hasPermission.value = true;
    
    // // Get initial location after permissions are granted
    // await getCurrentLocation();
    
    return true;
  }

  void showLocationDisabledDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Services Disabled'),
        content: Text(
          kIsWeb
              ? 'Please enable location services in your browser settings to use this feature.'
              : 'Location services are disabled. Please enable location services in your device settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          if (!kIsWeb)
            TextButton(
              onPressed: () async {
                Get.back();
                await location!.requestService();
              },
              child: const Text('Enable'),
            ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs access to location to show nearby properties. Please grant location permission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await checkLocationPermission();
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void showPermissionDeniedForeverDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text(
          'Location permission is permanently denied. Please enable it from app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<LocationPermissionService> init() async {
    await checkLocationPermission();
    return this;
  }

  // Add method to get current location
  Future<void> getCurrentLocation() async {
    try {
      isLocationLoading.value = true;
      
      if (!isLocationEnabled.value || !hasPermission.value) {
        await checkLocationPermission();
      }

      if (!isLocationEnabled.value || !hasPermission.value) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;
    } catch (e) {
      print('Error getting location: $e');
      // You might want to show an error dialog here
    } finally {
      isLocationLoading.value = false;
    }

    getCurrentLocation2();
  }

  Future<void> getCurrentLocation2() async {
    final locationService = Get.find<LocationService>();
    try{
      final place = await locationRepository.getLocation(LatLng(latitude.value!, longitude.value!));
       locationService.place.value = place;
    }catch(e){
      print('Error getting location: $e');
    }
  }

  // Add method to check if we have valid coordinates
  bool hasValidLocation() {
    return latitude.value != null && longitude.value != null;
  }

  // Add method to get formatted location string
  String? getFormattedLocation() {
    if (!hasValidLocation()) return null;
    return '${latitude.value!.toStringAsFixed(6)}, ${longitude.value!.toStringAsFixed(6)}';
  }
} 