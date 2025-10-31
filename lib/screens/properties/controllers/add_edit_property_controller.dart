import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/common/widgets/confirmation_dialog.dart';
import 'package:homy/common/widgets/custom_button.dart';
import 'package:homy/models/category.dart';
import 'package:homy/models/media.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/models/property/property_type_model.dart';
import 'package:homy/models/settings/settings_model.dart';
import 'package:homy/repositories/properties_respository.dart';
import 'package:homy/screens/location/pick_map_screen.dart';
import 'package:homy/services/categories_service.dart';
import 'package:homy/utils/app_constant.dart';
import 'package:homy/utils/constants/text_strings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class AddEditPropertyScreenController extends GetxController {
  List<dynamic> propertyTab = [
    'Overview',
    'Location',
    'Attributes',
    'Media',
    'Pricing'
  ];

  int screenType;

  ScrollController scrollController = ScrollController();
  ScrollController pageScrollController = ScrollController();
  Map<String, dynamic> param = {};
  Map<String, List<XFile>> filesMap = {};
  // PrefService prefService = PrefService();

  PropertyData? propertyData = Get.arguments;

  AddEditPropertyScreenController(this.screenType);
  CategoriesService categoriesService = Get.find<CategoriesService>();
  final propertiesRepository = PropertiesRepository();

  bool showErrors = false;
  bool showErrorsOverview = false;
  bool showErrorsLocation = false;
  bool showErrorsAttributes = false;
  bool showErrorsMedia = false;
  bool showErrorsPricing = false;

  // Add this to track expanded sections
  final List<bool> expandedSections = List.generate(7, (_) => false);

  // Add this method to toggle sections
  void toggleSection(int index) {
    expandedSections[index] = !expandedSections[index];
    update();
  }

  final titleFocus = FocusNode();
  final aboutFocus = FocusNode();

  // Add new TextEditingControllers for additional utilities
  final TextEditingController mallController = TextEditingController();
  final TextEditingController restaurantController = TextEditingController();
  final TextEditingController busStopController = TextEditingController();

  @override
  void onClose() {
    titleFocus.dispose();
    aboutFocus.dispose();
    mallController.dispose();
    restaurantController.dispose();
    busStopController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    getPrefData();
    super.onInit();
  }

  Future<void> getPrefData() async {
    // await prefService.init();
    // setting = prefService.getSettingData();




    getPropertyType(selectPropertyCategoryIndex);
    if (screenType == 1) {

      propertyTitleController =
          TextEditingController(text: propertyData?.title ?? '');
      areaController =
          TextEditingController(text: propertyData?.area.toString() ?? '');
      aboutPropertyController =
          TextEditingController(text: propertyData?.about ?? '');
      if (propertyData?.propertyCategory != null) {
        selectPropertyCategoryIndex = propertyData?.propertyCategory ?? 0;
        selectPropertyCategory =
            propertyCategoryList[selectPropertyCategoryIndex];
        getPropertyType(selectPropertyCategoryIndex);
      }

inspectionFeeController = TextEditingController(text: propertyData?.tourBookingFee.toString() ?? '');
      firstPriceController = TextEditingController(text: propertyData?.firstPrice.toString() ?? '');
        secondPriceController = TextEditingController(text: propertyData?.secondPrice.toString() ?? '');



      if (propertyData?.propertyTypeId != null) {
        // selectedPropertyType = setting?.propertyType?.firstWhere((element) {
        //   return element.id == propertyData?.propertyTypeId;
        // });
      }


      if (selectPropertyCategoryIndex == 0 && propertyData?.bedrooms != null && propertyData?.bedrooms != 0) {
        selectedBedrooms = CommonFun.getBedRoomList().firstWhere((element) {
          return element == propertyData?.bedrooms.toString();
        });
      }

      if (propertyData?.bathrooms != null) {
        selectedBathrooms = CommonFun.getBathRoomList().firstWhere((element) {
          return element == propertyData?.bathrooms.toString();
        });
      }

      propertyAddressController =
          TextEditingController(text: propertyData?.address ?? '');
      if (propertyData?.latitude != null || propertyData?.latitude != '0') {
        latLng = LatLng(double.parse(propertyData?.latitude ?? '0'),
            double.parse(propertyData?.longitude ?? '0'));
      }



      if (selectPropertyCategoryIndex == 0) {
        hospitalController =
            TextEditingController(text: propertyData?.farFromHospital ?? '');
        schoolController =
            TextEditingController(text: propertyData?.farFromSchool ?? '');
        gymController =
            TextEditingController(text: propertyData?.farFromGym ?? '');
        marketController =
            TextEditingController(text: propertyData?.farFromMarket ?? '');
        gasolineController =
            TextEditingController(text: propertyData?.farFromGasoline ?? '');
        airportController =
            TextEditingController(text: propertyData?.farFromAirport ?? '');
      }


      
      societyNameController =
          TextEditingController(text: propertyData?.societyName ?? '');
      builtYearController =
          TextEditingController(text: propertyData?.builtYear.toString() ?? '');


      selectedFurniture =
          propertyData?.furniture == 0 ? 'Not Furnished' : 'facing';



    if(propertyData?.facing != null && propertyData?.facing != 'null'){
      selectedFacing = CommonFun.facingList.firstWhere((element) {
        return element == propertyData?.facing;
      });
    }



if(propertyData?.totalFloors != null){
      selectedTotalFloor = CommonFun.getTotalFloorsList().firstWhere((element) {
        return element == propertyData?.totalFloors.toString();
      });
}

  Get.log('propertyData: ${propertyData?.floorNumber}');

      // selectedTotalFloor = CommonFun.getTotalFloorsList().firstWhere((element) {
      //   return element == propertyData?.totalFloors.toString();
      // });
      

if(propertyData?.floorNumber != null){
      selectedFloorNumber = CommonFun.getFloorsList().firstWhere((element) {
        return element == propertyData?.floorNumber.toString();
      });
}

      if(propertyData?.carParkings != null){
        selectedCarParking = CommonFun.getCarParkingList().firstWhere((element) {
        return element == propertyData?.carParkings.toString();
      });
}


      maintenanceMonthController = TextEditingController(
          text: propertyData?.maintenanceMonth.toString() ?? '');



      if (propertyData?.media != null || propertyData!.media!.isNotEmpty) {
        for (int i = 0; i < (propertyData?.media?.length ?? 0); i++) {
          Media? m = propertyData?.media?[i];
          Get.log('mmmmmmmmm: ${m?.mediaTypeId}');

          if (m?.mediaTypeId == 1) {
            overviewMedia.add(m!);
          }
          if (m?.mediaTypeId == 2) {
            bedRoomMedia.add(m!);
          }
          if (m?.mediaTypeId == 3) {
            bathRoomMedia.add(m!);
          }
          if (m?.mediaTypeId == 4) {
            floorPlanMedia.add(m!);
          }
          if (m?.mediaTypeId == 5) {
            otherMedia.add(m!);
          }
          if (m?.mediaTypeId == 6) {
            threeSixtyMedia.add(m!);
          }
          if (m?.mediaTypeId == 7) {
            networkPropertyVideoThumbnail = m?.thumbnail;
            propertyVideoMedia = m!;
          }
        }
      }
      firstPriceController = TextEditingController(
        text: propertyData?.firstPrice.toString() ?? '',
      );
      if (propertyData?.secondPrice != null) {
        secondPriceController = TextEditingController(
          text: propertyData?.secondPrice.toString() ?? '',
        );
      }
      availablePropertyIndex = propertyData?.propertyAvailableFor ?? 0;
    }
    update();
  }

  /// -------------------------- Top bar tabView -------------------------- ///
  int selectedTabIndex = 0;

  void onTabClick(int index) {
    selectedTabIndex = index;
    pageScrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
    update();
    if (index > 3) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200), curve: Curves.linear);
    } else {
      scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 200), curve: Curves.linear);
    }
  }

  /// -------------------------- Overview -------------------------- ///
  TextEditingController propertyTitleController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController aboutPropertyController = TextEditingController();
  int selectPropertyCategoryIndex = 0;
  String? selectedBedrooms;
  String? selectedBathrooms;
  String selectPropertyCategory = CommonFun.propertyCategoryList.first;
  List<String> propertyCategoryList = CommonFun.propertyCategoryList;

  SettingsModel? setting;
  List<Category> propertyType = [];
  Category? selectedPropertyType;

  List<Category> propertyTypeList = [];
  List<PropertyType> selectedList = [];
  // Api Calling
  Future<void> getPropertyType(int type) async {
    propertyType = [];
    propertyTypeList = await categoriesService.getAllCategories();
    for (var element in propertyTypeList) {
      if (element.propertyType == type) {
        Get.log(element.toJson());
        propertyType.add(element);
        update();
      }
    }
    // propertyType = [];
    // setting?.propertyType?.forEach((element) {
    //   if (element.propertyCategory == type) {
    //     propertyType.add(element);
    //     update();
    //   }
    // });
  }

  // DropBox Function
  void onPropertyCategoryClick(value) async {
    selectPropertyCategory = value;
    selectPropertyCategoryIndex = propertyCategoryList.indexOf(value);
    selectedPropertyType = null;
    selectedBedrooms = null;
    hospitalController = TextEditingController(text: '');
    schoolController = TextEditingController(text: '');
    gymController = TextEditingController(text: '');
    marketController = TextEditingController(text: '');
    gasolineController = TextEditingController(text: '');
    airportController = TextEditingController(text: '');
    getPropertyType(selectPropertyCategoryIndex);
    update();
  }

  void onPropertyTypeClick(Category? value) {
    selectedPropertyType = value;
    update();
  }

  void onBedroomsClick(value) {
    selectedBedrooms = value;
    update();
  }

  onBathroomsClick(value) {
    selectedBathrooms = value;
    update();
  }

  /// -------------------------- Location -------------------------- ///
  TextEditingController propertyAddressController = TextEditingController();
  TextEditingController hospitalController = TextEditingController();
  TextEditingController schoolController = TextEditingController();
  TextEditingController gymController = TextEditingController();
  TextEditingController marketController = TextEditingController();
  TextEditingController gasolineController = TextEditingController();
  TextEditingController airportController = TextEditingController();
  LatLng? latLng;

  void onFetchLocation() {
    if (latLng == null) {
      Get.showSnackbar(CommonUI.infoSnackBar(
          message: 'Please fetch your property location'));
    }

    Get.to(() => PickMapScreen(
        fromAddAddress: false,
        fromLandingPage: true,
        onPicked: (place) {
          print('place');
          print(place);
          latLng = LatLng(
              double.parse(place.latitude!), double.parse(place.longitude!));
          // selectedLocationName = place.description;
          Get.log('latLng: ${latLng}');
          update();
        }));

    // Get.to(() => MapScreen(
    //       latLng: latLng ?? const LatLng(0, 0),
    //     ))?.then((value) {
    //   if (value != null) {
    //     latLng = value;
    //     update();
    //   }
    // });
  }

  /// -------------------------- Attributes -------------------------- ///
  TextEditingController societyNameController = TextEditingController();
  TextEditingController builtYearController = TextEditingController();
  TextEditingController maintenanceMonthController = TextEditingController();
  String selectedFurniture = CommonFun.furnitureList.first;
  String? selectedFacing;
  String? selectedTotalFloor;
  String? selectedFloorNumber;
  String? selectedCarParking;

  // DropBox Function
  onFurnitureClick(value) {
    selectedFurniture = value;
    update();
  }

  onFacingClick(value) {
    selectedFacing = value;
    update();
  }

  onTotalFloorClick(value) {
    selectedTotalFloor = value;
    update();
  }

  onFloorNumberClick(value) {
    selectedFloorNumber = value;
    update();
  }

  onCarParkingClick(value) {
    selectedCarParking = value;
    update();
  }

  /// -------------------------- Media -------------------------- ///
  ImagePicker picker = ImagePicker();
  List<XFile> overviewImages = [];
  List<XFile> bedRoomImages = [];
  List<XFile> bathRoomImages = [];
  List<XFile> floorPlanImages = [];
  List<XFile> otherImages = [];
  List<XFile> threeSixtyImages = [];
  XFile? propertyVideo;

  List<Media> overviewMedia = [];
  List<Media> bedRoomMedia = [];
  List<Media> bathRoomMedia = [];
  List<Media> floorPlanMedia = [];
  List<Media> otherMedia = [];
  List<Media> threeSixtyMedia = [];
  Media? propertyVideoMedia;
  XFile? propertyVideoThumbnail;
  String? networkPropertyVideoThumbnail;
  List<String> removeMediaId = [];

  /// pick multiple image fun
  void pickMultipleImage(int imageType) async {
    final List<XFile> images = await picker.pickMultiImage(
      maxHeight: cMaxHeightImage,
      maxWidth: cMaxWidthImage,
      imageQuality: cQualityImage,
    );
    if (images.isNotEmpty) {
      if (imageType == 0) {
        for (int i = 0; i < images.length; i++) {
          overviewImages.add(images[i]);
          overviewMedia.add(Media(id: -1, content: images[i].path));
        }
      }
      if (imageType == 1) {
        for (int i = 0; i < images.length; i++) {
          bedRoomImages.add(images[i]);
          bedRoomMedia.add(Media(id: -1, content: images[i].path));
        }
      }
      if (imageType == 2) {
        for (int i = 0; i < images.length; i++) {
          bathRoomImages.add(images[i]);
          bathRoomMedia.add(Media(id: -1, content: images[i].path));
        }
      }
      if (imageType == 3) {
        for (int i = 0; i < images.length; i++) {
          floorPlanImages.add(images[i]);
          floorPlanMedia.add(Media(id: -1, content: images[i].path));
        }
      }
      if (imageType == 4) {
        for (int i = 0; i < images.length; i++) {
          otherImages.add(images[i]);
          otherMedia.add(Media(id: -1, content: images[i].path));
        }
      }
      if (imageType == 5) {
        for (int i = 0; i < images.length; i++) {
          threeSixtyImages.add(images[i]);
          threeSixtyMedia.add(Media(id: -1, content: images[i].path));
        }
      }
    }
    update();
  }

  void pickPropertyVideo() async {
    if (propertyVideoThumbnail == null &&
        networkPropertyVideoThumbnail == null) {
      await picker.pickVideo(source: ImageSource.gallery).then(
        (value) async {
          if (value != null) {
            if (CommonFun.getSizeInMb(value) <= Constant.maximumVideoSizeInMb) {
              await VideoThumbnail.thumbnailFile(
                      video: value.path,
                      imageFormat: ImageFormat.JPEG,
                      quality: cQualityVideo,
                      maxWidth: cMaxWidthVideo,
                      maxHeight: cMaxHeightVideo)
                  .then((v) {
                if (v != null) {
                  propertyVideoThumbnail = XFile(v);
                }
                propertyVideo = value;
                update();
              });
            } else {
              Get.dialog(
                ConfirmationDialog(
                  title1: 'Too Large Video',
                  title2: 'This video is greater than 100MB',
                  onPositiveTap: () {
                    Get.back();
                    pickPropertyVideo();
                  },
                  aspectRatio: 1 / 0.5,
                ),
              );
            }
          }
        },
      );
    } else {
      removeMediaId.add(propertyVideoMedia?.id.toString() ?? '');
      propertyVideoThumbnail = null;
      networkPropertyVideoThumbnail = null;
      propertyVideo = null;
      propertyVideoMedia = null;
      update();
    }
  }

  /// image delete function
  void onImageDeleteTap(int imageIndex, int imageType) {
    if (imageType == 0) {
      XFile? imageOne;
      for (XFile image in overviewImages) {
        if (image.path == overviewMedia[imageIndex].content) {
          imageOne = image;
        }
      }
      if (imageOne != null) {
        overviewImages.remove(imageOne);
      }
      removeMediaId.add(overviewMedia[imageIndex].id.toString());
      overviewMedia.removeAt(imageIndex);
    }
    if (imageType == 1) {
      XFile? imageOne;
      for (XFile image in bedRoomImages) {
        if (image.path == bedRoomMedia[imageIndex].content) {
          imageOne = image;
        }
      }
      if (imageOne != null) {
        bedRoomImages.remove(imageOne);
      }
      removeMediaId.add(bedRoomMedia[imageIndex].id.toString());
      bedRoomMedia.removeAt(imageIndex);
    }
    if (imageType == 2) {
      XFile? imageOne;
      for (XFile image in bathRoomImages) {
        if (image.path == bathRoomMedia[imageIndex].content) {
          imageOne = image;
        }
      }
      if (imageOne != null) {
        bathRoomImages.remove(imageOne);
      }
      removeMediaId.add(bathRoomMedia[imageIndex].id.toString());
      bathRoomMedia.removeAt(imageIndex);
    }
    if (imageType == 3) {
      XFile? imageOne;
      for (XFile image in floorPlanImages) {
        if (image.path == floorPlanMedia[imageIndex].content) {
          imageOne = image;
        }
      }
      if (imageOne != null) {
        floorPlanImages.remove(imageOne);
      }
      removeMediaId.add(floorPlanMedia[imageIndex].id.toString());
      floorPlanMedia.removeAt(imageIndex);
    }
    if (imageType == 4) {
      XFile? imageOne;
      for (XFile image in otherImages) {
        if (image.path == otherMedia[imageIndex].content) {
          imageOne = image;
        }
      }
      if (imageOne != null) {
        otherImages.remove(imageOne);
      }
      removeMediaId.add(otherMedia[imageIndex].id.toString());
      otherMedia.removeAt(imageIndex);
    }
    if (imageType == 5) {
      XFile? imageOne;
      for (XFile image in threeSixtyImages) {
        if (image.path == threeSixtyMedia[imageIndex].content) {
          imageOne = image;
        }
      }
      if (imageOne != null) {
        threeSixtyImages.remove(imageOne);
      }
      removeMediaId.add(threeSixtyMedia[imageIndex].id.toString());
      threeSixtyMedia.removeAt(imageIndex);
    }
    update();
  }

  /// -------------------------- Pricing -------------------------- ///

  TextEditingController firstPriceController = TextEditingController();
  TextEditingController secondPriceController = TextEditingController();
  TextEditingController inspectionFeeController = TextEditingController();

  List<String> availableProperty = ['For Sale', 'For Rent'];
  int availablePropertyIndex = 0;

  void onAvailablePropertyClick(int index) {
    availablePropertyIndex = index;
    firstPriceController.clear();
    update();
  }

  bool isOverview() {
    showErrorsOverview = true;
    update();

    if (propertyTitleController.text.isEmpty) {
      return false;
    }
    if (selectedPropertyType == null) {
      return false;
    }
    if (selectPropertyCategoryIndex == 0) {
      if (selectedBedrooms == null) {
        return false;
      }
    }
    if (selectedBathrooms == null) {
      return false;
    }
    if (aboutPropertyController.text.isEmpty) {
      return false;
    }

    showErrorsOverview = false;
    update();
    return true;
  }

  bool isLocation() {
    showErrorsLocation = true;
    update();
    if (propertyAddressController.text.isEmpty) {
      return false;
    }
    if (latLng == null) {
      CommonUI.ErrorSnackBar(title: 'Please fetch your property location');
      Get.showSnackbar( CommonUI.infoSnackBar(message: 'Please fetch your property location'));
      return false;
    }
    if (selectPropertyCategoryIndex == 0) {
      if (hospitalController.text.isEmpty) {
        CommonUI.ErrorSnackBar(title: 'Please enter hospital distance');
        // return false;
      }
      if (schoolController.text.isEmpty) {
        CommonUI.ErrorSnackBar(title: 'Please enter school distance');
        // return false;
      }
      if (gymController.text.isEmpty) {
        CommonUI.ErrorSnackBar(title: 'Please enter gym distance');
        // return false;
      }
      if (marketController.text.isEmpty) {
        CommonUI.ErrorSnackBar(title: 'Please enter market distance');
        // return false;
      }
      if (gasolineController.text.isEmpty) {
        CommonUI.ErrorSnackBar(title: 'Please enter gasoline distance');
        // return false;
      }
      if (airportController.text.isEmpty) {
        CommonUI.ErrorSnackBar(title: 'Please enter airport distance');
        // return false;
      }
    }
    showErrorsLocation = false;
    update();
    return true;
  }

  bool isAttributes() {
//     if (societyNameController.text.isEmpty) {
// Get.showSnackbar( CommonUI.infoSnackBar(message: 'Please enter property address'));
//       return false;
//     }
    // if (builtYearController.text.isEmpty) {
    //   Get.showSnackbar( CommonUI.infoSnackBar(message: 'Please enter built year'));
    //   return false;
    // }
    // if (selectedFacing == null) {
    //   Get.showSnackbar( CommonUI.infoSnackBar(message: 'Please select your building face'));
    //   return false;
    // }
    //   if (selectedTotalFloor == null) {
    //         Get.showSnackbar(CommonUI.infoSnackBar(message: 'Please select your building face'));
    //   }
    //   if (selectedFloorNumber == null) {
    //  Get.showSnackbar(CommonUI.infoSnackBar(message: 'Please select your floor number'));
    //   }
    // if (selectedCarParking == null) {
    //   Get.showSnackbar(CommonUI.infoSnackBar(message: 'Please select car parking'));
    // }
    // if (maintenanceMonthController.text.isEmpty) {
    //    Get.showSnackbar(CommonUI.infoSnackBar(message: 'Please enter maintenance in month amount'));
    //   return false;
    // }
    return true;
  }

  bool isMedia() {
    showErrorsMedia = true;
    update();

    if (overviewImages.isEmpty && overviewMedia.isEmpty) {
      return false;
    }

    showErrorsMedia = false;
    update();
    return true;
  }

  bool isPricing() {
    showErrorsPricing = true;
    update();
    if (firstPriceController.text.isEmpty) {
      Get.showSnackbar(
          CommonUI.infoSnackBar(message: 'Please enter property price'));
      return false;
    }
    if (availablePropertyIndex == 1) {
      secondPriceController.clear();
    }
    showErrorsPricing = false;
    update();
    return true;
  }

  /// Submit Click
  bool isLoading = false;

  void onSubmitClick() {
    if (selectedTabIndex == 0) {
      if (isOverview()) {
        selectedTabIndex = 1;
        update();
        return;
      } else {
        return;
      }
    }

    if (selectedTabIndex == 1) {
      if (isLocation()) {
        selectedTabIndex = 2;
        update();
        return;
      } else {
        return;
      }
    }

    if (selectedTabIndex == 2) {
      if (isAttributes()) {
        selectedTabIndex = 3;
        update();
        return;
      } else {
        return;
      }
    }
    if (selectedTabIndex == 3) {
      if (isMedia()) {
        selectedTabIndex = 4;
        update();
        return;
      } else {
        return;
      }
    }
    if (selectedTabIndex == 4) {
      if (!isPricing()) {
        update();
        return;
      }
    }

    if (!isOverview()) {
      selectedTabIndex = 0;
      update();
      return;
    }

    if (!isLocation()) {
      selectedTabIndex = 1;
      update();
      return;
    }

    if (!isAttributes()) {
      selectedTabIndex = 2;
      update();
      return;
    }

    if (!isMedia()) {
      selectedTabIndex = 3;
      update();
      return;
    }

    if (!isPricing()) {
      selectedTabIndex = 4;
      update();
      return;
    }
    isLoading = true;
    update();

    if (screenType == 1) {
      param[uPropertyId] = propertyData?.id.toString();
    }

    param[uTitle] = propertyTitleController.text;
    param[uPropertyCategory] = selectPropertyCategoryIndex.toString();
    param[uPropertyTypeId] = selectedPropertyType?.id.toString();
    param[uBedrooms] = selectedBedrooms ?? '0';
    param[uBathrooms] = selectedBathrooms;
    param[uArea] = areaController.text.isEmpty ? '0' : areaController.text;
    param[uAbout] = aboutPropertyController.text;
    param[uAddress] = propertyAddressController.text;
    param[uLatitude] = latLng?.latitude.toString();
    param[uLongitude] = latLng?.longitude.toString();

    // Initialize the distance map if it doesn't exist
    param['extra_detail'] = param['extra_detail'] ?? {};
    param['extra_detail'][uFarFromHospital] = hospitalController.text;
    param['extra_detail'][uFarFromSchool] = schoolController.text;
    param['extra_detail'][uFarFromGym] = gymController.text;
    param['extra_detail'][uFarFromMarket] = marketController.text;
    param['extra_detail'][uFarFromGasoline] = gasolineController.text;
    param['extra_detail'][uFarFromAirport] = airportController.text;

    param['extra_detail'][uSocietyName] = societyNameController.text;
    param['extra_detail'][uBuiltYear] = builtYearController.text;
    param['extra_detail'][uFurniture] =
        selectedFurniture == CommonFun.furnitureList.first ? '1' : '0';
    param['extra_detail'][uFacing] = selectedFacing;
    param['extra_detail'][uTotalFloors] = selectedTotalFloor;
    param['extra_detail'][uFloorNumber] = selectedFloorNumber;
    param['extra_detail'][uCarParkings] = selectedCarParking;
    param['extra_detail'][uMaintenanceMonth] = maintenanceMonthController.text;

    filesMap[uOverviewsImage] = overviewImages;

    if (bedRoomImages.isNotEmpty) {
      filesMap[uBedroomImage] = bedRoomImages;
    }
    if (bathRoomImages.isNotEmpty) {
      filesMap[uBathroomImage] = bathRoomImages;
    }
    if (floorPlanImages.isNotEmpty) {
      filesMap[uFloorPlanImage] = floorPlanImages;
    }
    if (otherImages.isNotEmpty) {
      filesMap[uOtherImageImage] = otherImages;
    }
    if (threeSixtyImages.isNotEmpty) {
      filesMap[uThreeSixtyImage] = threeSixtyImages;
    }
    if (propertyVideo != null) {
      filesMap[uPropertyVideo] = [propertyVideo!];
      filesMap[uThumbnail] = [propertyVideoThumbnail!];
    }

    param[uPropertyAvailableFor] = availablePropertyIndex == 1 ? 'rent' : 'sales';
    param[uFirstPrice] = firstPriceController.text.replaceAll(',', '');
    param[uSecondPrice] = secondPriceController.text.replaceAll(',', '');

    param[uInspectionFee] = inspectionFeeController.text.isEmpty ? '0' : inspectionFeeController.text.replaceAll(',', '');

    if (availablePropertyIndex == 1) {
      param[uRentPeriod] = selectedRentPeriod.toString();
    }
    if (screenType == 1) {
      if (removeMediaId.isNotEmpty) {
        param[uRemoveMediaId] = removeMediaId;
      }
    }

    Get.log('param: ${param}');
    CommonUI.loader();
    handlePropertyApiCall(
        param: param, filesMap: filesMap, screenType: screenType);
  }

  Future<void> handlePropertyApiCall(
      {required int screenType,
      required Map<String, List<XFile>> filesMap,
      required Map<String, dynamic> param}) async {
    var response = await propertiesRepository.addProperty(
        param: param, filesMap: filesMap);

    if (response != null && response['status'] == 200) {

      _handleApiResponse(screenType, response);
    }
    isLoading = false;
    update();
    // Get.back();
    // Define the URL based on the screen type
    // final String url = screenType == 0 ? UrlRes.addProperty : UrlRes.editProperty;

    // // Call the API with the specified URL, files, and parameters
    // ApiService().multiPartCallApi(
    //   url: url,
    //   filesMap: filesMap,
    //   param: param,
    //   completion: (response) {
    //     // Handle the API response
    //     _handleApiResponse(screenType, response);
    //   },
    // );
  }

  void _handleApiResponse(int screenType, dynamic response) {
    Get.back(); // Dismiss loader

    if (response != null && response['status'] == 200) {
      // Show success dialog
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  screenType == 0
                      ? 'Property Added Successfully!'
                      : 'Property Updated Successfully!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  response['message'] ??
                      'Your property has been successfully saved.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  buttonText: 'Done',
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Go back to previous screen
                      Get.back(); 
                    // Optionally refresh the properties list
                    // Get.find<HomeController>().getProperties();
                  },
                )

// ElevatedButton(
//                   onPressed: () {
//                     Get.back(); // Close dialog
//                     Get.back(); // Go back to previous screen
//                     // Optionally refresh the properties list
//                     // Get.find<HomeController>().getProperties();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     minimumSize: const Size(double.infinity, 45),
//                   ),
//                   child: const Text('Done'),
//                 ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } else {
      // Show error message
      Get.showSnackbar(
        CommonUI.ErrorSnackBar(
          message:
              response?['message'] ?? 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  int selectedRentPeriod = 1; // 0: Daily, 1: Monthly, 2: Yearly

  void onRentPeriodSelect(int? index) {
    if (index != null) {
      selectedRentPeriod = index;
      update();
    }
  }
}
