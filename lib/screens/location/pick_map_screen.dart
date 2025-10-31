import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/location/address_model.dart';
import 'package:homy/models/place_model.dart';
import 'package:homy/screens/location/controllers/location_controller.dart';
import 'package:homy/screens/location/widgets/serach_location_widget.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/dimensions.dart';
import 'package:homy/utils/theme/theme_controller.dart';

import '../../common/widgets/custom_button.dart';

class PickMapScreen extends StatefulWidget {
  final bool? fromSignUp;
  final bool? fromAddAddress;
  final bool? canRoute;
  final String? route;
  final GoogleMapController? googleMapController;
  final Function(PlaceModel place)? onPicked;
  final bool fromLandingPage;
  const PickMapScreen({super.key,
     this.fromSignUp,  this.fromAddAddress,  this.canRoute, this.onPicked,
     this.route, this.googleMapController, this.fromLandingPage = false,
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  LatLng _initialPosition = const LatLng(51.5236, -0.0998); // Default to London coordinates
  bool locationAlreadyAllow = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  bool _darkTheme = false;
  Color? _lightColor;
  Color? _darkColor;

  bool get darkTheme => _darkTheme;
  Color? get darkColor => _darkColor;
  Color? get lightColor => _lightColor;

  String _lightMap = '[]';
  String get lightMap => _lightMap;

  String _darkMap = '[]';
  String get darkMap => _darkMap;

  void _initializeMap() async {
    // First check location permission
     _lightMap = await rootBundle.loadString('assets/map/light_map.json');
     _darkMap = await rootBundle.loadString('assets/map/dark_map.json');
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // If we have permission, get current location
    if (permission == LocationPermission.whileInUse || 
        permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition();
        Get.log('position: ${position.latitude} ${position.longitude}');
        if (mounted) { // Check if widget is still mounted before setState
          setState(() {
            _initialPosition = LatLng(position.latitude, position.longitude);
            locationAlreadyAllow = true;
          });
        }
      } catch (e) {
        Get.log('Error getting position: $e');
        // No need to set fallback position since we already have default
      }
    }

    if(widget.fromAddAddress ?? false) {
      Get.find<LocationController>().setPickData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: GetBuilder<LocationController>(
          builder: (locationController) {
            // Use null check for fromAddAddress and position
            final target = (widget.fromAddAddress ?? false) && 
                          locationController.position != null
                ? LatLng(locationController.position.latitude, 
                        locationController.position.longitude)
                : _initialPosition;

            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: target,
                    zoom: 16,
                  ),
                  // myLocationEnabled: true, // Enable blue dot for current location
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (GoogleMapController mapController) async {
                    _mapController = mapController;
                    await Future.delayed(const Duration(seconds: 0));
                    // Get.find<LocationController>().getCurrentLocation(false, mapController: mapController);

                    if(!(widget.fromAddAddress ?? false)) {
                      Get.find<LocationController>().getCurrentLocation(false, mapController: mapController);
                    }
                  },
                  minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                  scrollGesturesEnabled: !Get.isDialogOpen!,
                  onCameraMove: (CameraPosition cameraPosition) {
                    _cameraPosition = cameraPosition;
                  },
                  onCameraMoveStarted: () {
                    locationController.disableButton();
                  },
                  onCameraIdle: () {
                    Get.find<LocationController>().updatePosition(_cameraPosition, false);
                  },
                  style: Get.isDarkMode ? darkMap : lightMap,
                ),

                Center(child: !locationController.loading ? Image.asset(MImages.pickMarker, height: 50, width: 50)
                    : const CircularProgressIndicator()),

                Positioned(
                  top: Dimensions.paddingSizeLarge, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                  child: SafeArea(child: SearchLocationWidget(mapController: _mapController, pickedAddress: locationController.pickAddress, isEnabled: null)),
                ),

                Positioned(
                  bottom: 80, right: Dimensions.paddingSizeLarge,
                  child: FloatingActionButton(
                    mini: true, backgroundColor: Theme.of(context).cardColor,
                    onPressed: () => Get.find<LocationController>().checkPermission(() {
                      Get.find<LocationController>().getCurrentLocation(false, mapController: _mapController);
                    }),
                    child: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
                  ),
                ),

                Positioned(
                  bottom: Dimensions.paddingSizeLarge, left: Dimensions.paddingSizeLarge, right: Dimensions.paddingSizeLarge,
                  child: CustomButton(
                    buttonText: locationController.inZone ? widget.fromAddAddress ?? false ? 'Pick Address'.tr : 'Pick Location'.tr
                        : 'Service Not Available In This Area'.tr,
                    isLoading: locationController.isLoading,
                    onPressed: locationController.isLoading ? (){} : (locationController.buttonDisabled || locationController.loading) ? null : () {
                      _onPickAddressButtonPressed(locationController);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onPickAddressButtonPressed(LocationController locationController) {
    if(locationController.pickPosition.latitude != 0 && locationController.pickAddress!.isNotEmpty) {
      if(widget.onPicked != null) {
        PlaceModel place = PlaceModel(
          placeId: '1',
          latitude: locationController.pickPosition.latitude.toString(),
          longitude: locationController.pickPosition.longitude.toString(),
          description: locationController.pickAddress ?? '',
        );
        widget.onPicked!(place);
        Get.back();
      }else if(widget.fromAddAddress ?? false) {
        if(widget.googleMapController != null) {
          widget.googleMapController!.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
            locationController.pickPosition.latitude, locationController.pickPosition.longitude,
          ), zoom: 16)));
          locationController.setAddAddressData();
        }
        Get.back();
      }else {
        PlaceModel place = PlaceModel(
          placeId: '1',
          latitude: locationController.pickPosition.latitude.toString(),
          longitude: locationController.pickPosition.longitude.toString(),
          description: locationController.pickAddress ?? '',
        );
         Get.back();
        // AddressModel address = AddressModel(
        //   latitude: locationController.pickPosition.latitude.toString(),
        //   longitude: locationController.pickPosition.longitude.toString(),
        //   addressType: 'others', address: locationController.pickAddress,
        // );

        // if(widget.fromLandingPage) {
        //   if(!AuthHelper.isGuestLoggedIn() && !AuthHelper.isLoggedIn()) {
        //     Get.find<AuthController>().guestLogin().then((response) {
        //       if(response.isSuccess) {
        //         Get.find<ProfileController>().setForceFullyUserEmpty();
        //         Get.back();
        //         locationController.saveAddressAndNavigate(
        //           address, widget.fromSignUp, widget.route, widget.canRoute, ResponsiveHelper.isDesktop(Get.context),
        //         );
        //       }
        //     });
        //   } else {
        //     Get.back();
        //     locationController.saveAddressAndNavigate(
        //       address, widget.fromSignUp, widget.route, widget.canRoute, ResponsiveHelper.isDesktop(context),
        //     );
        //   }
        // }else {
        //   locationController.saveAddressAndNavigate(
        //     address, widget.fromSignUp, widget.route, widget.canRoute, ResponsiveHelper.isDesktop(context),
        //   );
        // }
      }
    }else {
     CommonUI.showCustomSnackBar('pick_an_address'.tr);
    }
  }

  Future<bool> _locationCheck() async {
    bool locationServiceEnabled = true;
    LocationPermission permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.denied) {
      locationServiceEnabled = false;
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.deniedForever) {
      locationServiceEnabled = false;
    }
    return locationServiceEnabled;
  }

}
