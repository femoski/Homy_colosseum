import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/common/widgets/confirmation_dialog.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/utils/theme/theme.dart';

import '../../../repositories/user_repository.dart';

class SettingsScreenController extends GetxController {
  // PrefService prefService = PrefService();
  UserData? savedUser;
  String? password;
  int notificationStatus = 1;
  Function(int type, UserData? userData)? onUpdate;
  final selectedThemeMode = ThemeMode.light.obs;
  RxBool isDarkMode = false.obs;
  final _storage = GetStorage();
  final authService = Get.find<AuthService>();
  UserData? user;
  SettingsScreenController(this.onUpdate);

  UserRepository userRepository = UserRepository();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  final RxBool isDeleting = false.obs;

  @override
  void onInit() {
    getPrefData();
    super.onInit();
    _loadThemeMode();
    user = authService.user.value;
  }

  void _loadThemeMode() {
    String? themeMode = _storage.read<String>('theme_mode');
    isDarkMode.value = themeMode == 'ThemeMode.dark';
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;

    // Update storage
    await _storage.write(
        'theme_mode', isDarkMode.value ? 'ThemeMode.dark' : 'ThemeMode.light');

    // Update theme mode
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // Update system UI
    MAppTheme.setSystemUIOverlayStyle(!isDarkMode.value);
  }

  void onLogoutClick() {
    Get.dialog(ConfirmationDialog(
        title1: 'Logout',
        title2: 'Are you sure you want to log out',
        positiveText: 'Logout',
        onPositiveTap: () async {
          Get.back();
          CommonUI.loader();
          try {
            await userRepository.logout();
            Get.back();
            Get.showSnackbar(
                CommonUI.SuccessSnackBar(message: 'Logout Successfully'));
            AuthHelper.logout();
            user = null;
            update();
          } catch (e) {
            Get.back();
            CommonUI.snackBar(title: e.toString());
          }
        },
        aspectRatio: 2));

    update();
  }

  void onDeleteAccountClick() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to delete your account? This action cannot be undone.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter your password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Tell us why you\'re leaving...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  Obx(() => ElevatedButton(
                        onPressed: isDeleting.value
                            ? null
                            : () {
                                if (passwordController.text.isEmpty) {
                                  CommonUI.snackBar(
                                      title: 'Please enter your password');
                                  return;
                                }
                                deleteAccountApiCall();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          elevation: 0,
                          side: BorderSide.none,
                        ),
                        child: isDeleting.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text('Delete',
                                style: TextStyle(color: Colors.white)),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteAccountApiCall() async {
    isDeleting.value = true;
    try {
      await userRepository.deleteAccount(
        password: passwordController.text,
        reason: reasonController.text,
      );
      Get.back();
      Get.showSnackbar(
          CommonUI.SuccessSnackBar(message: 'Account deleted successfully'));
      // Clear the controllers
      passwordController.clear();
      reasonController.clear();
      // Logout after successful deletion
      AuthHelper.logout();
    } catch (e) {
      isDeleting.value = false;
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  void getPrefData() async {
    // await prefService.init();
    // savedUser = prefService.getUserData();
    // if (savedUser != null) {
    //   notificationStatus = savedUser?.isNotification ?? 1;
    // }
    // firebaseUser = FirebaseAuth.instance.currentUser;
    // password = prefService.getString(key: pPassword);
    update();
  }

  void onNotificationTap() {
    if (notificationStatus == 1) {
      notificationStatus = 0;
    } else {
      notificationStatus = 1;
    }
    onUpdate?.call(1, UserData(isNotification: notificationStatus));
    update();
    // ApiService().multiPartCallApi(
    //     completion: (response) async {
    //       FetchUser fetchUser = FetchUser.fromJson(response);
    //       if (fetchUser.status == true) {
    //         if (notificationStatus == 0) {
    //           FirebaseNotificationManager.shared.unsubscribeToTopic();
    //         } else {
    //           FirebaseNotificationManager.shared.subscribeToTopic(fetchUser.data);
    //         }
    //       } else {
    //         notificationStatus = notificationStatus == 1 ? 0 : 1;
    //         onUpdate?.call(1, UserData(isNotification: notificationStatus));
    //       }
    //       update();
    //     },
    //     url: UrlRes.editProfile,
    //     param: {uUserId: savedUser?.id, uIsNotification: notificationStatus},
    //     filesMap: {});
  }

  void onNavigateSubscriptionScreen() {
    //   Get.to<UserData?>(() => const SubscriptionScreen())?.then(
    //     (value) {
    //       if (value != null) {
    //         savedUser = value;
    //       onUpdate?.call(3, savedUser);
    //       update();
    //     }
    //   },
    // );
  }

  // void onLogout() async {
  //   await AuthHelper.logout();
  //   Get.offAllNamed('/login');
  // }
}
