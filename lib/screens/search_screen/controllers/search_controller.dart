import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/models/category.dart';
import 'package:homy/models/place_model.dart';
import 'package:homy/models/property/property_type_model.dart';
import 'package:homy/screens/location/pick_map_screen.dart';
import 'package:homy/services/categories_service.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/constants/text_strings.dart';


class SearchScreenController extends GetxController {
  String uPropertyIDs = 'PropertyID';
  String uLocationID = 'LocationID';
  String uPropertyCategoryID = 'PropertyCategoryID';
  String uPriceRangeID = 'PriceRangeID';
  String uAreaRangeID = 'AreaRangeID';
  String uBathroomID = 'BathroomID';
  String uBedroomID = 'BedroomID';

  int selectedType = 0;
  int selectLocationIndex = 0;
  int selectPropertyCategory = 0;
  double radiusValue = 0;

  List<String> propertyType = CommonFun.propertyTypeList;
  List<String> locationType = CommonFun.locationTypeList;
  List<String> propertyCategory = CommonFun.propertyCategoryList;
    List<Category> commercialCategory = [];
  List<Category> residentialCategory = [];

  Category? selectedProperty;
  String? selectBathRoom;
  String? selectBedroom;
  double priceFrom = Constant.minPriceRange;
  double priceTo = Constant.maxPriceRange;
  double areaFrom = Constant.minAreaRange;
  double areaTo = Constant.maxAreaRange;
  // PrefService prefService = PrefService();

  List<Category> propertyTypeList = [];
  List<PropertyType> selectedList = [];

  LatLng? latLng;

  CategoriesService categoriesService = Get.find<CategoriesService>();
  
  bool showLocationError = false;

  @override
  void onReady() {
    getPrefData();
    super.onReady();
  }

  void getPrefData() async {

    propertyTypeList = await categoriesService.getAllCategories();
    for (var element in propertyTypeList) {
      if (element.propertyType == 0) {
        residentialCategory.add(element);
      } else {
        commercialCategory.add(element);
      }
    }
    update([uPropertyCategoryID]);
    // Get.back();

    // categoriesService.getAllCategories().then((value) {
    //   propertyTypeList = value;
    //   update([uPropertyCategoryID]);
    // });
    // CommonUI.loader();
    // await prefService.init();
    // propertyTypeList = prefService.getSettingData()?.propertyType ?? [];
    // for (var element in propertyTypeList) {
    //   if (element.propertyCategory == 0) {
    //     residentialCategory.add(element);
    //   } else {
    //     commercialCategory.add(element);
    //   }
    // }
    // update([uPropertyCategoryID]);
    // Get.back();
  }

  void onTypeChange(int index) {
    selectedType = index;
    update([uPropertyIDs]);
  }

  void onLocationTabChange(int index) {
    selectLocationIndex = index;
    selectedLocationName = '';
    latLng = null;
    update([uLocationID]);
  }

  void onRadiusChange(double value) {
    radiusValue = value;
    update([uLocationID]);
  }

  void onSelectPropertyCategory(int index) {
    selectPropertyCategory = index;
    update([uPropertyCategoryID, uBedroomID]);
  }

  void onPropertySelected(Category index) {
    if (selectedProperty == index) {
      selectedProperty = null;
    } else {
      selectedProperty = index;
    }
    update([uPropertyCategoryID]);
  }

  void onPriceRangeChange(RangeValues value) {
    priceFrom = value.start;
    priceTo = value.end;
    update([uPriceRangeID]);
  }

  void onAreaRangeChange(RangeValues value) {
    areaFrom = value.start;
    areaTo = value.end;
    update([uAreaRangeID]);
  }

  void onBathRoomChange(String? value) {
    selectBathRoom = value;
    update([uBathroomID]);
  }

  void onBedRoomChange(String? value) {
    selectBedroom = value;
    update([uBedroomID]);
  }

  String selectedLocationName = '';
  String selectedCity = '';

  Future<void> onLocationCardClick() async {
     if (selectLocationIndex == 0) {
        final place = await Get.toNamed('/search-place');
        if (place != null) {
          final placeModel = place as PlaceModel;
            latLng = LatLng(double.parse(placeModel.latitude!), double.parse(placeModel.longitude!));
          selectedLocationName = placeModel.description;
        selectedCity = place.city ?? '';
             showLocationError = false;

          update([uLocationID]);
        }
      } else {
        // Get.toNamed('/pick-map',arguments: {
        //   'fromLandingPage': true,
        //   'onPicked': (place) {
        //     print('place');
        //     print(place);
        //     latLng = LatLng(double.parse(place.latitude!), double.parse(place.longitude!));
        //     selectedLocationName = place.description;
        //     update([uLocationID]);
        //   }
        // });
       Get.to(() => PickMapScreen(
          fromAddAddress: false, 
          fromLandingPage: true,
          onPicked: (place) {
            print('place');
            print(place);
            latLng = LatLng(double.parse(place.latitude!), double.parse(place.longitude!));
            selectedLocationName = place.description;
            Get.log('latLng: ${uLocationID}');
             showLocationError = false;
            update([uLocationID]);
          }
        ));
        // if (place != null) {
        //   final placeModel = place as PlaceModel;
        //   latLng = LatLng(double.parse(placeModel.latitude!), double.parse(placeModel.longitude!));
        //   selectedLocationName = placeModel.description;
        //   update([uLocationID]);
        // }

        // Get.to(() => SearchPlaceScreen(screenType: 1, latLng: latLng ?? const LatLng(0, 0)))?.then((value) {
        //   if (value != null) {
        //     latLng = LatLng(value[uUserLatitude], value[uUserLongitude]);
        //     selectedLocationName = value[pSelectCity];
        //     update([uLocationID]);
        //   }
        // });
      
      // Get.to(() => SearchPlaceScreen(screenType: 1, latLng: latLng ?? const LatLng(0, 0)))?.then((value) {
      //   if (value != null) {
      //     latLng = LatLng(value[uUserLatitude], value[uUserLongitude]);
      //     selectedLocationName = value[pSelectCity];
      //     update([uLocationID]);
      //   }
      // });
     }
    // if (selectLocationIndex == 0) {
    //   Get.to(() => SearchPlaceScreen(screenType: 1, latLng: latLng ?? const LatLng(0, 0)))?.then((value) {
    //     if (value != null) {
    //       latLng = LatLng(value[uUserLatitude], value[uUserLongitude]);
    //       selectedLocationName = value[pSelectCity];
    //       update([uLocationID]);
    //     }
    //   });
    // } else {
    //   Get.to<LatLng>(() => MapScreen(
    //         latLng: latLng ?? const LatLng(0, 0),
    //       ))?.then((value) {
    //     if (value != null) {
    //       latLng = LatLng(value.latitude, value.longitude);
    //       selectedLocationName = '${latLng?.latitude.toStringAsFixed(3)} , ${latLng?.longitude.toStringAsFixed(3)}';
    //       update([uLocationID]);
    //     }
    //   });
    // }
  }

  void onResetBtnClick() {
    selectedType = 0;
    selectLocationIndex = 0;
    selectPropertyCategory = 0;
    radiusValue = 0;
    selectedProperty = null;
    selectBathRoom = null;
    selectBedroom = null;
    priceFrom = Constant.minPriceRange;
    priceTo = Constant.maxPriceRange;
    areaFrom = Constant.minAreaRange;
    areaTo = Constant.maxAreaRange;
    latLng = null;
    update([
      uPropertyIDs,
      uLocationID,
      uPropertyCategoryID,
      uPriceRangeID,
      uAreaRangeID,
      uBathroomID,
      uBedroomID,
    ]);
  }

  void onSearchBtnClick(
      {required int newSearchType, required SearchScreenController controller, required BuildContext context}) {
     if (selectedLocationName.isEmpty) {
      showLocationError = true;
      update([uLocationID]);
      return;
    }
    showLocationError = false;
    // ... rest of your navigation logic
    Map<String, dynamic> map = {};
    if (selectedType == 0) {
    }
    else{
      map['type'] = selectedType==1?'rent':'sales';
    }

    // if (selectedCity.isNotEmpty) {
    //   map['city'] = selectedCity;
    // }
    if (selectedProperty != null) {
      // map[uPropertyTypeId] = selectedProperty?.id.toString();

         if (selectedType == 0) {
    }
    else{
      map['type'] = selectedType==1?'rent':'sales';
    }

      map['property_category'] = selectedProperty?.slug;
      map['category'] = selectedProperty?.id;

    }
    if (selectBathRoom != null) {
      map[uBathrooms] = selectBathRoom;
    }
    if (selectBedroom != null && selectPropertyCategory == 0) {
      map[uBedrooms] = selectBedroom;
    }
    map[uPriceFrom] = priceFrom.toInt().toString();
    map[uPriceTo] = priceTo.toInt().toString();

    map[uAreaFrom] = areaFrom.toInt().toString();
    map[uAreaTo] = areaTo.toInt().toString();

    if (selectLocationIndex == 0 && selectedCity.isNotEmpty) {
      map['city'] = selectedCity;
    } else if (selectLocationIndex == 1 && selectedLocationName.isNotEmpty) {
      map['location'] = selectedLocationName;
      
        if (latLng != null) {
      map[uUserLatitude] = latLng?.latitude.toString();
      map[uUserLongitude] = latLng?.longitude.toString();
      map[uRadius] = radiusValue.toString();
    }
    }
  

  // if (latLng != null) {
  //     map[uUserLatitude] = latLng?.latitude.toString();
  //     map[uUserLongitude] = latLng?.longitude.toString();
  //     map[uRadius] = radiusValue.toString();
  //   }

    // map[uPropertyAvailableFor] = selectedType == 0
    //     ? '2'
    //     : selectedType == 1
    //         ? '1'
    //         : '0';
  



 
    Get.log('map: ${map}');

    Get.toNamed('/properties/$selectedType', arguments: {
      'type': selectedProperty,
      'map': map,
      'screenType': 1,
    });
    // NavigateService.push(
    //   context,
    //   PropertyTypeScreen(
    //     type: selectedProperty,
    //     map: map,
    //     screenType: 1,
    //   ),
    // );
  }

  void onNextPage() {
    if (selectedLocationName.isEmpty) {
      showLocationError = true;
      update([uLocationID]);
      return;
    }
    showLocationError = false;
    // ... rest of your navigation logic
  }

  void onLocationSelected(String location) {
    selectedLocationName = location;
    showLocationError = false;
    update([uLocationID]);
  }
}
