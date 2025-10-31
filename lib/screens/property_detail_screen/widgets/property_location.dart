import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/screens/property_detail_screen/controllers/property_detail_controller.dart';
import 'package:homy/screens/property_detail_screen/widgets/property_header.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/my_text_style.dart';

class PropertyLocation extends GetView<PropertyDetailScreenController> {
  @override
  Widget build(BuildContext context) {
    PropertyData? data = controller.propertyData;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PropertyHeading(title: 'Property Location'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.theme.colorScheme.outline.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                controller.isMapVisible 
                    ? MapCardCustom(data: data) 
                    : const SizedBox(height: 160),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: context.theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.propertyData?.address ?? '',
                          style: MyTextStyle.productLight(
                            color: context.theme.colorScheme.onSurface,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class MapCardCustom extends StatefulWidget {
  final PropertyData? data;

  const MapCardCustom({
    super.key,
    required this.data,
  });

  @override
  State<MapCardCustom> createState() => _MapCardCustomState();
}

class _MapCardCustomState extends State<MapCardCustom> with AutomaticKeepAliveClientMixin {
  String? mapStyle;
  PropertyData? data;
  bool _isMapReady = false;

  GoogleMapController? mapController;

  Map<MarkerId, Marker> markers = {};
  double latitude = 0;
  double longitude = 0;

  @override
  bool get wantKeepAlive => true; // This prevents the widget from being disposed during scroll

  @override
  void initState() {
    super.initState();
    mapTheme();
    data = widget.data;
    if (data != null) {
      getPropertyLocation();
    }
  }

  @override
  void didUpdateWidget(covariant MapCardCustom oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != data) {
      data = widget.data;
      if (data != null) {
        getPropertyLocation();
      }
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  void mapTheme() {
    rootBundle.loadString(MImages.googleMapStyle).then((string) {
      if (mounted) {
        setState(() {
          mapStyle = string;
        });
      }
    });
  }

  void getPropertyLocation() async {
    if (data == null) return;
    
    try {
      latitude = double.parse(data?.latitude ?? '0');
      longitude = double.parse(data?.longitude ?? '0');
      
      if (mapController != null && _isMapReady) {
        mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 14.4746,
        )));
      }

      var marker = Marker(
        markerId: const MarkerId('0'),
        position: LatLng(latitude, longitude),
        // icon: BitmapDescriptor.bytes(markIcons),
      );
      
      if (mounted) {
        setState(() {
          markers[const MarkerId('0')] = marker;
        });
      }
    } catch (e) {
      print('Error parsing coordinates: $e');
    }
  }

  // declared method to get Images
  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Container(
      height: 180,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          if(!kIsWeb)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 14.4746,
              ),
              onMapCreated: (controller) {
                mapController = controller;
                if (mapStyle != null) {
                  mapController?.setMapStyle(mapStyle);
                }
                setState(() {
                  _isMapReady = true;
                });
                // Set initial position after map is ready
                if (latitude != 0 && longitude != 0) {
                  getPropertyLocation();
                }
              },
              markers: markers.values.toSet(),
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              // Add these properties to improve performance
              compassEnabled: false,
              mapToolbarEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Material(
          //     elevation: 2,
          //     borderRadius: BorderRadius.circular(12),
          //     color: latitude != 0 
          //         ? context.theme.colorScheme.primary 
          //         : context.theme.colorScheme.onPrimary,
          //     child: InkWell(
          //       onTap: () async {
          //         if (latitude != 0) {
          //           // Your existing navigation code
          //         }
          //       },
          //       borderRadius: BorderRadius.circular(12),
          //       child: Container(
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 16,
          //           vertical: 10,
          //         ),
          //         child: Row(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             // Icon(
          //             //   Icons.assistant_navigation,
          //             //   color: context.theme.colorScheme.onPrimary,
          //             //   size: 20,
          //             // ),
          //             const SizedBox(width: 8),
          //             // Text(
          //             //   "Navigate",
          //             //   style: MyTextStyle.productMedium(
          //             //     color: context.theme.colorScheme.onPrimary,
          //             //     size: 14,
          //             //   ),
          //             // ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
