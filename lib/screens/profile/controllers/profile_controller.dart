import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/models/reels/reels_model.dart';
import 'package:homy/repositories/user_repository.dart';
import 'package:homy/screens/followers/followers.dart';
import 'package:homy/services/auth_service.dart';

import '../../../common/ui.dart';
import '../../../models/users/fetch_user.dart';
import '../../auth/login/login_modal.dart';

class ProfileController extends GetxController {
  // final UserData? AuthService;
  final authService = Get.find<AuthService>();
  Rx<UserData>? user;
  final userRepository = UserRepository();

  ProfileController()
  {
    user = authService.user;
  }

  @override
  void onReady() {
    super.onReady();
    if(AuthHelper.isLoggedIn()){
    loadProfile();
    }

  }


  void loadProfile() async {
    await fetchProfile();
    await fetchReels();
    update();
  }
  Future<void> fetchReels() async {
    try {
      final response = await userRepository.getUserReels(authService.id);
      // Update the reels list and notify listeners

      
        authService.user.update((user) {
          user?.yourReels = response;
          // return user;
        });
            Get.log('response: ${authService.user.value.toJson()}');

      // Keep local user in sync
      user?.update((val) {
        val?.yourReels = response;
        // return val;
      });
      update();
    } catch (e) {
      print('Error fetching reels: $e');
    }
  }


  Future<void> fetchProfile() async {
    try {
      final response = await userRepository.fetchProfile();
      // Update the user data and notify listeners
      // authService.user.update((val) {
      //   val = response;
      //   // return val;
      // });
      // user?.update((val) {
      //   val = response;
      //   // return val;
      // });

      // update();
      authService.user.value = response;

    } catch (e) {
      print('Error fetching profile: $e');
    }
  }



  onNavigateUserList(int i, UserData? user) {
    Get.to(
            () => FollowersFollowingScreen(
                  followFollowingType: i == 0 ? FollowFollowingType.followers : FollowFollowingType.following,
                  userId: user?.id,
                ),
            preventDuplicates: true)
        ?.then(
      (value) {
        // fetchProfile();
      },
    );

  }

  void showLoginmodal()
  {
    Get.bottomSheet(LoginModal(onLoginComplete: (value) {
      if(value){
        Get.back();
        update();
      }
    }), enableDrag: true,isScrollControlled: true);
  }

  
    onDeleteReel(ReelData? reelData) {
    authService.user.value.yourReels?.removeWhere((element) => element.id == reelData?.id);
    // CommonUI.snackBar(title: 'Reel deleted successfully');
    update();
  }

  onUpdateReelsList(ReelData? reelData) {
    authService.user.value.yourReels?.add(reelData!);
    update();
  }
}
