import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/common/widgets/ads_widget.dart';
import 'package:homy/models/chat/chat_list.dart';
import 'package:homy/models/chat/property_message.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/repositories/properties_respository.dart';
import 'package:homy/screens/chat_screen/message_box.dart';
import 'package:homy/screens/property_detail_screen/properties_image.dart';
import 'package:homy/screens/reels_screen/widgets/reel_helper.dart';
import 'package:homy/screens/schedule_tour/schedule_tour.dart';
import 'package:homy/utils/helpers/helper_utils.dart';

import '../../../repositories/saved_repository.dart';

class PropertyDetailScreenController extends GetxController {
  double maxExtent = 350;
  double currentExtent = 350.0;
  ScrollController scrollController = ScrollController();
  PropertyData? propertyData;
  // PrefService prefService = PrefService();
  int? propertyId;
  bool isReadMore = true;
  bool isLoading = true;

  GoogleMapController? mapController;

  bool isMapVisible = true;
  UserData? savedUser;
  final Function(UserData? userData)? onUpdate;
  final Function(ReelUpdateType type, ReelData data)? onUpdateReel;

  // static PropertyDetailScreenController get argument {
  //   final args = Get.arguments;
  //   if (args is PropertyDetailScreenController) {
  //     return args;
  //   }
  //   throw 'Invalid argument type passed to PropertyDetailScreen';
  // }
  int get property_Id => int.parse(Get.currentRoute.split('/').last);
  final Map<String, dynamic>? property_id = Get.arguments;

  bool isScrollingDown = false;
  bool isScrolledToBottom = false;
  double previousScrollPosition = 0;

  final propertiesRepository = PropertiesRepository();
  final savedRepository = SavedRepository();
  PropertyDetailScreenController(
      this.propertyId, this.onUpdate, this.onUpdateReel);

  @override
  void onReady() {
    super.onReady();
    getPrefData();
    initScrollController();
    print("property_id: $property_id");
  }

  void fetchPropertyDetailApiCall() async {
    // if (propertyData == null) {
    //   CommonUI.loader();
    // }

    try {
      // Get mock data
      PropertyData? data =
          await propertiesRepository.fetchPropertyDetail(property_Id);
      isLoading = false;
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (data != null) {
        propertyData = data;
      } else {
        Get.showSnackbar(CommonUI.ErrorSnackBar(message: 'Property not found'));
        // CommonUI.ErrorSnackBar(title: 'Property not found');
      }
      update();
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
    }
  }

  Future<void> onPropertySaved(PropertyData? data) async {
    if (!AuthHelper.isLoggedIn()) {
      Get.showSnackbar(CommonUI.infoSnackBar(message: 'You are not logged in'));
      return;
    }
    
    String? savedPropertyId = savedUser?.savedPropertyIds;
    List<String> savedId = [];
    if (savedPropertyId == null || savedPropertyId.isEmpty) {
      savedPropertyId = data?.id.toString();
    } else {
      savedId = savedPropertyId.split(',');
      if (savedPropertyId.contains(data?.id.toString() ?? '')) {
        savedId.remove(data?.id.toString() ?? '');
      } else {
        savedId.add(data?.id.toString() ?? '');
      }
      savedPropertyId = savedId.join(',');
    }

    if (data?.savedProperty == true) {
      propertyData?.savedProperty = false;
    } else {
      propertyData?.savedProperty = true;
    }
    update();
    await savedRepository.togglePropertySave(property_Id);

    // ApiService().call(
    //   url: UrlRes.editProfile,
    //   param: {uUserId: PrefService.id.toString(), uSavedPropertyIds: savedPropertyId},
    //   completion: (response) async {
    //     FetchUser editProfile = FetchUser.fromJson(response);
    //     savedUser = editProfile.data;
    //     await prefService.saveUser(editProfile.data);
    //     fetchPropertyDetailApiCall();
    //   },
    // );
  }

  void getPrefData() async {
    fetchPropertyDetailApiCall();

    if (!kIsWeb) {
      InterstitialAdsService.shared.loadAd();
    }
    update();
  }

  void shareProperty() {
    if (propertyData?.id == null) return;
    
    HelperUtils.share(Get.context!, propertyData!.id!);
  }

  void onReadMoreTap() {
    isReadMore = !isReadMore;
    update();
  }

  void initScrollController() {
    scrollController = ScrollController()
      ..addListener(() {
        currentExtent = maxExtent - scrollController.offset;
        if (currentExtent < 0) {
          currentExtent = 0.0;
        }
        if (currentExtent > maxExtent) {
          currentExtent = maxExtent;
        }
        if (scrollController.offset > 800) {
          isMapVisible = false;
        } else {
          isMapVisible = true;
        }

        // Check scroll direction
        if (scrollController.position.pixels > previousScrollPosition) {
          if (!isScrollingDown) {
            isScrollingDown = true;
            update();
          }
        } else {
          if (isScrollingDown) {
            isScrollingDown = false;
            update();
          }
        }
        previousScrollPosition = scrollController.position.pixels;

        // Check if scrolled to bottom section
        double bottomThreshold =
            scrollController.position.maxScrollExtent - Get.height * 0.8;
        if (scrollController.position.pixels >= bottomThreshold) {
          if (!isScrolledToBottom) {
            isScrolledToBottom = true;
            update();
          }
        } else {
          if (isScrolledToBottom) {
            isScrolledToBottom = false;
            update();
          }
        }

        update();
      });
  }

  void onMessageClick(int screenType) {
    if (!AuthHelper.isLoggedIn()) {
      Get.showSnackbar(CommonUI.infoSnackBar(message: 'You are not logged in'));
      return;
    }

    String convId = CommonFun.getConversationId(
        AuthHelper.getUserId(), propertyData?.user?.id ?? 0);

    ChatListItem? conversation = ChatListItem(
      chatTime: 0,
      unreadCount: 0,
      isTyping: false,
      user: ChatUsers(
        userId: propertyData?.user?.id.toString() ?? '',
        username: propertyData?.user?.fullname ?? '',
        email: propertyData?.user?.email ?? '',
        avatar: propertyData?.user?.avatar ?? '',
        name: propertyData?.user?.fullname ?? '',
      ),
    );

    List<String> propertyImage = [];
    propertyData?.media?.forEach((element) {
      if (element.mediaTypeId != 7) {
        propertyImage.add(element.content ?? '');
      }
    });

    PropertyMessage property = PropertyMessage(
      propertyId: propertyData?.id,
      image: propertyImage,
      title: propertyData?.title,
      message:
          'Please provide me more details on this property. I am interested in this property!',
      address: propertyData?.address,
      propertyType: propertyData?.propertyType,
    );

    Get.to(
      () => MessageBox(
        conversation: conversation,
        screen: 1,
        onUpdateUser: (blockUnBlock) {
          update();
        },
      ),
      arguments: property,
    )?.then((value) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });

    // convert Conversation Id

    // String convId =
    //     CommonFun.getConversationId(savedUser?.id, propertyData?.userId);

    // Conversation conversation = Conversation(
    //   conversationId: convId,
    //   deletedId: 0,
    //   iBlocked: false,
    //   iAmBlocked: false,
    //   isDeleted: false,
    //   lastMessage: '',
    //   newMessage:
    //       'Please provide me more details on this property. I am interested in this property!',
    //   time: DateTime.now().millisecondsSinceEpoch,
    //   user: ChatUser(
    //       userID: propertyData?.user?.id,
    //       image: propertyData?.user?.avatar,
    //       userType: propertyData?.user?.userType,
    //       identity: propertyData?.user?.email,
    //       msgCount: 0,
    //       name: propertyData?.user?.fullname,
    //       verificationStatus: propertyData?.user?.verificationStatus),
    // );

    // PropertyMessage property = PropertyMessage(
    //   propertyId: propertyData?.id,
    //   image: propertyImage,
    //   title: propertyData?.title,
    //   message: 'Please provide me more details on this property. I am interested in this property!',
    //   address: propertyData?.address,
    //   propertyType: propertyData?.propertyAvailableFor,
    // );
    isMapVisible = false;
    update();
    // Get.to(
    //   () => MessageBox(
    //     conversation: conversation,
    //     // propertyMessage: property,
    //     screen: screenType,
    //   ),
    // )?.then((value) {
    //   SystemChrome.setPreferredOrientations(
    //       [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    // });
  }

  void onPopupMenuTap(String value) {
    if (value == '/share') {
      shareProperty();
    } else if (value == '/report') {
      isMapVisible = false;
      update();
      // Get.to(() =>
      //         ReportScreen(reportUserData: propertyData?.user, reportType: ReportType.property, property: propertyData))
      //     ?.then(
      //   (value) {
      //     isMapVisible = true;
      //     update();
      //   },
      // );
    }
  }

  void onNavigateUserProfile(PropertyData? data) {
    print('data?.userId: ${data}');
    isMapVisible = false;
    update();
    Get.log('Navigating to user profile with userId: ${data?.user?.id}');
    Get.toNamed('/enquire-info/${data?.user?.id}', arguments: data?.user);
    // Get.to(() => EnquireInfoScreen(userId: data?.userId ?? -1, onUpdate: onUpdate, onUpdateReel: onUpdateReel));
  }

  void onNavigateImageScreen(int index) {
    isMapVisible = false;
    update();
    Get.to(() => ImagesScreen(
        image: propertyData?.media ?? [], selectImageTab: index))?.then(
      (value) {
        isMapVisible = true;
        update();
      },
    );
  }

  void onNavigateVideoScreen() {
    isMapVisible = false;
    update();
    // Get.to(PreviewVideoScreen(
    //   url: CommonFun.getMedia(m: propertyData?.media ?? [], mediaId: 7),
    // ));
  }

  void onNavigateFloorPlan() {
    isMapVisible = false;
    update();
    // Get.to(() => FloorPlansScreen(
    //       media: propertyData?.media ?? [],
    //     ));
  }

  void onNavigateScheduledScreen() {
    if (!AuthHelper.isLoggedIn()) {
      Get.showSnackbar(CommonUI.infoSnackBar(message: 'You are not logged in'));
      return;
    }

    isMapVisible = false;
    update();
    Get.to(() => ScheduleTourScreen(propertyData: propertyData));
  }

  void onContactOwner() {
    // Implement contact owner logic
  }
}
