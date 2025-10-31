import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/widgets/custom_button.dart';
import 'package:homy/utils/lotti/lotti_editor.dart';
import 'package:lottie/lottie.dart';
import 'package:homy/screens/auth/login/login_modal.dart';

class NotLoggedInScreen extends StatelessWidget {
  final Function(bool success) callBack;
  NotLoggedInScreen({super.key, required this.callBack});

  final noLoginData = LottieEditor.noLoggedIn;

  void _showLoginBottomSheet() {
    Get.bottomSheet(
      LoginModal(
        onLoginComplete: (success) {
          Get.back();
          callBack(success);
        },
      ),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      enterBottomSheetDuration: const Duration(milliseconds: 300),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // minHeight: MediaQuery.of(context).size.height -
          //     MediaQuery.of(context).padding.top -
          //     MediaQuery.of(context).padding.bottom,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie Animation
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Lottie.asset(
                      'assets/lottie/no_logged_in.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Title with Container
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'You are not logged in'.tr,
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.primaryColor,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Please login to continue'.tr,
                    style: Get.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Login Button with animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0.8, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: SizedBox(
                        width: 220,
                        child: CustomButton(
                          buttonText: 'Login'.tr,
                          height: 50,
                          radius: 25,
                          onPressed: _showLoginBottomSheet,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
