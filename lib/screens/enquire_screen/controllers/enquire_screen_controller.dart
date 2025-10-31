import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/common/widgets/confirmation_dialog.dart';
import 'package:homy/common/widgets/user_report_dialog.dart';
import 'package:homy/models/chat/chat_list.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/repositories/followers_repository.dart';
import 'package:homy/repositories/properties_respository.dart';
import 'package:homy/repositories/reels_repository.dart';
import 'package:homy/repositories/user_repository.dart';
import 'package:homy/screens/chat_screen/message_box.dart';
import 'package:homy/screens/reels_screen/widgets/reel_helper.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/utils/constants.dart';
import 'package:homy/utils/helpers/helper_utils.dart';

import '../../../Helper/AuthHelper.dart';
import '../../../common/widgets/user_block_dialog.dart';


class EnquireInfoScreenController extends GetxController {
  // Update key
  UserData? userData = Get.arguments;
  String updatePropertyList = 'updatePropertyList';
  String updateFollowUnFollowButton = 'updateFollowUnFollowButton';

  ScrollController scrollController = ScrollController();
  // PrefService prefService = PrefService();
 String? user_id = '';
  int selectedTabIndex = 0;
  bool isLoading = false;
  bool isPropertyLoading = false;
  bool isReelLoading = false;
  UserData? otherUserData;
  UserData? myUserData;
  String? otherUserID;
  List<PropertyData> propertyList = [];
  List<ReelData> reels = [];

  bool isBlock = false;
  bool isMoreAbout = false;
  double opacity = 0.0;
  bool _functionCalled = false;
  AuthService authService= Get.find<AuthService>();


  bool hasMoreProperty = true;
  bool hasMoreReel = true;
  Function(UserData?)? onUpdate;
  Function(ReelUpdateType type, ReelData data)? onUpdateReel;

  bool showStickyHeader = false;
  final double stickyHeaderThreshold = 56.0; // Adjust based on your top bar height
final  userRepository= UserRepository();
final  propertyRepository= PropertiesRepository();
final  reelRepository= ReelsRepository();

  Map<String, String?> userID = Get.parameters;

  final followerRepository = FollowersRepository();

  EnquireInfoScreenController(this.otherUserID, this.onUpdate, this.onUpdateReel);


  @override
  void onReady() {
    super.onReady();
    _loadMoreData();
    fetchApi();
  }

  void fetchApi() async {
    // await prefService.init();
    // myUserData = prefService.getUserData();
    Get.log('userData: ${userData?.toJson()}');
    if(userData?.isBlock == 1){
      isBlock = true;
      update();
    }
   await _fetchProfile(true);
    if(userData?.role != 'agent'){
      selectedTabIndex = 2;
    }
    Get.log('authService: ${authService.user.value.id}');
    await _fetchMyProperty();
    await _fetchReel();
  }

  void onTabTap(int i) {
    selectedTabIndex = i;
    print('selectedTabIndex: $selectedTabIndex');
    update();
  }

  Future<void> _fetchMyProperty() async {
    if (!hasMoreProperty) return;
    isPropertyLoading = true;
    update();


if(userData?.id != null){
 user_id = userData?.id.toString();
}
else{
  user_id = userID['id'].toString();
}
try{
   propertyList= await propertyRepository.getUserProperties(int.parse(user_id ?? '0'));
 
}catch(e){
  Get.log('errororrr: $e');
}

       isPropertyLoading = false;
           update();

      update([updatePropertyList]);

  }

  void _loadMoreData() {
    scrollController.addListener(() {
      _changeOpacity();
      if (scrollController.offset >= scrollController.position.maxScrollExtent) {
        if (!isPropertyLoading && selectedTabIndex == 0) {
          _fetchMyProperty();
        } else if (!isReelLoading && selectedTabIndex == 2) {
          _fetchReel();
        }
      }
    });
  }

  _changeOpacity() {
    double offset = scrollController.offset;
    double newOpacity = (offset - 100) / 50; // Starts increasing opacity after offset 100
    if (newOpacity < 0) newOpacity = 0;
    if (newOpacity > 1) newOpacity = 1;

    if (offset >= 100 && !_functionCalled) {
      _functionCalled = true; // Ensure the function is called only once
    } else if (offset < 100 && _functionCalled) {
      _functionCalled = false; // Reset the flag if scrolled back
    }

    opacity = newOpacity;
    update();
  }

  Future<void> _fetchProfile(bool loading) async {
    isLoading = loading;

    // await Future.delayed(const Duration(seconds: 2));

     try{
if(userData?.id != null){
  Get.log('userID2222: ${userData?.id}');

    userData = await userRepository.getUserProfile(userData?.id ?? -1);
    if(userData?.isBlock==1){
      isBlock = true;
      update();
    }
    update();

}else if(userID['id'] != null){
      userData = await userRepository.getUserProfile(int.parse(userID['id'] ?? '0'));
      if(userData?.isBlock==1){
      isBlock = true;
      update();
    }
    update();

// userRepository.getUserProfile(userData?.id ?? -1).then((value) {
}

}catch(e){
  Get.log('errororrr: $e');
}
     otherUserData = userData;
     if(otherUserData?.isBlock==1){
      isBlock = true;
      update();
    }
    // userData = MockPropertyData.getDummyUserById(4);
    // Get.log('otherUserData: ${otherUserData?.toJson()}');

    update();
 
  }

  void onMoreBtnClick(int index) async {

    if(!AuthHelper.isLoggedIn()) {

      Get.showSnackbar(CommonUI.infoSnackBar(message: 'You are not logged in'));
      return;
    }
    if (index == 0) {
      /// Report
      if (otherUserData != null) {
        final result = await Get.dialog(
          UserReportDialog(
            userId: otherUserData!.id.toString(),
            userName: otherUserData!.fullname ?? 'Unknown',
          ),
        );

        if (result != null) {
          try {
            await userRepository.reportUser(
              userId: otherUserData!.id ?? -1,
              reason: result['reason'],
              additionalDetails: result['details'],
            );
            Get.back();
            CommonUI.snackBar(title: 'User reported successfully');
          } catch (e) {
            // Error handling is done in the repository
          }
        }
      } else {
        CommonUI.snackBar(title: 'User Not Found');
      }
    } else {
      /// Block/Unblock
      if (otherUserID == -1) {
        CommonUI.snackBar(title: 'User ID Not Found');
        return;
      }

      final result = await Get.dialog(
        UserBlockDialog(
          userId: otherUserData?.id.toString() ?? '',
          userName: otherUserData?.fullname ?? '',
          isBlocked: isBlock,
        ),
      );
        
     if (result != null) {
      isBlock = result;
      update();
      }
      //   ConfirmationDialog(
      //     aspectRatio: 2.1,
      //     positiveText: isBlock ? 'Unblock' : 'Block',
      //     title1: 'Block Unblock',
      //     title2: 'Are you sure you want to ${isBlock ? 'unblock' : 'block'} ${otherUserData?.fullname}?',
      //     onPositiveTap: () async {
      //       try {
      //         final blocked = await userRepository.toggleBlockUser(otherUserData?.id ?? -1);
      //         isBlock = blocked;
      //         update();
      //         Get.back();
      //         CommonUI.snackBar(
      //           title: blocked 
      //             ? 'User blocked successfully' 
      //             : 'User unblocked successfully'
      //         );
      //       } catch (e) {
      //         // Error handling is done in the repository
      //       }
      //     },
      //   ),
    
    }
  }

  void onShareBtnClick() async {

    HelperUtils.shareAll(
      Get.context!,
      title: 'Share ${otherUserData?.fullname ?? 'Unknown'} Profile',
      description: 'Check out ${otherUserData?.fullname ?? 'Unknown'} profile on Homy!',
      url: '${Constants.appBaseUrl}/app/user-profile/${HelperUtils.encryptReelId(otherUserData?.id)}',
    );
  }

  void onReadMoreClick() {
    isMoreAbout ? isMoreAbout = false : isMoreAbout = true;
    update();
  }

  Future<void> _fetchReel() async {
    if (!hasMoreReel) return;
    isReelLoading = true;


  try{
    if(userData?.id != null){
 user_id = userData?.id.toString();
}
else{
  user_id = userID['id'].toString();
}

  reels= await reelRepository.getUserReels(int.parse(user_id ?? '0'), 0);
  }catch(e){
    Get.log('Femi errrorr: $e');
  }
  isReelLoading = false;
  update(['reelsPage']);

    update();
  }

  void onFollowUnfollowTap() async {
    if (!AuthHelper.isLoggedIn()) {
      Get.showSnackbar(CommonUI.infoSnackBar(message: 'You are not logged in'));
      return;
    }

    if (isBlock) {
      return onMoreBtnClick(1);
    }

      bool isFollow = userData?.followingStatus == 2 || userData?.followingStatus == 3;


    final response = await followerRepository.toggleFollow(userData?.id ?? -1, isFollow);
      if (response['action']!=null) {
        if(response['action'] == 'unfollow'){
          userData?.followingStatus = 0;
        }else{
          userData?.followingStatus = 2;
        }
        // onUpdateReel?.call(ReelUpdateType.follow, userData);
        update();
      }


    // if (otherUserData?.followingStatus == 2 || otherUserData?.followingStatus == 3) {
    //   ApiService.instance.call(
    //       completion: (response) {
    //         Get.back();
    //         FollowUser followUser = FollowUser.fromJson(response);
    //         if (followUser.status == true) {
    //           otherUserData?.followingStatus = 0;
    //           _fetchProfile(false);
    //         }
    //       },
    //       url: UrlRes.unfollowUser,
    //       onError: () {
    //         Get.back();
    //       },
    //       param: {uMyUserId: PrefService.id, uUserId: otherUserID});
    // } else {
    //   ApiService.instance.call(
    //       completion: (response) {
    //         Get.back();
    //         FollowUser followUser = FollowUser.fromJson(response);
    //         if (followUser.status == true) {
    //           otherUserData?.followingStatus = 2;
    //           _fetchProfile(false);
    //         }
    //       },
    //       url: UrlRes.followUser,
    //       param: {
    //         uMyUserId: PrefService.id,
    //         uUserId: otherUserData?.id,
    //       });
    // }
  }

  void onNavigatePropertyDetail(BuildContext context, PropertyData? data) {
      // NavigateService.push(context, PropertyDetailScreen(propertyId: data?.id ?? -1)).then(
      //   (value) {},
      // );
  }

  onUpdateList(ReelUpdateType type, ReelData data) {
    onUpdateReel?.call(type, data);
  }

  onNavigateChat(UserData? userData) {
    if (!AuthHelper.isLoggedIn()) {
      Get.showSnackbar(CommonUI.infoSnackBar(message: 'You are not logged in'));
      return;
    }
    if (isBlock) {
      return onMoreBtnClick(
        1,
      );
    }

    String convId = CommonFun.getConversationId(AuthHelper.getUserId(), userData?.id ?? 0);

ChatListItem? conversation = ChatListItem(
  chatTime: 0,
  unreadCount: 0,
  isTyping: false,
  user: ChatUsers(
    userId: userData?.id.toString() ?? '',
    username: userData?.fullname ?? '',
    email: userData?.email ?? '',
    avatar: userData?.avatar ?? '',
    name: userData?.fullname ?? '',
  ),
);

    Get.to(
      () => MessageBox(
        conversation: conversation,
        screen: 1,
        onUpdateUser: (blockUnBlock) {
          isBlock = blockUnBlock == 1;
          update();
        },
      ),
    )?.then((value) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });
  }

  void updateStickyHeader(double scrollPosition) {
    bool shouldShow = scrollPosition > stickyHeaderThreshold;
    if (shouldShow != showStickyHeader) {
      showStickyHeader = shouldShow;
      update();
    }
  }
}
