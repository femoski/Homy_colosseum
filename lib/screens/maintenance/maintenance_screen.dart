import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../utils/my_text_style.dart';
import '../../services/config_service.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              Expanded(
                flex: 3,
                child: Center(
                  child: Lottie.asset(
                    'assets/lottie/maintancemode.json',
                    width: 500,
                    height: 500,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              // Text Content
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      configService.appConfig.maintenanceTitle.tr,
                      style: MyTextStyle.robotoBold.copyWith(
                        fontSize: 25,
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      configService.appConfig.maintenanceMessage.tr,
                      textAlign: TextAlign.center,
                      style: MyTextStyle.robotoMedium.copyWith(
                        fontSize: 18,
                        color: Get.theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // ElevatedButton(
                    //   onPressed: () => init(),
                    //   style: ElevatedButton.styleFrom(
                    //     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //   ),
                    //   child: Text('Retry'.tr),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> init() async {
    final configService = await ConfigService.getConfig();
    if (configService.config.value?.maintenance != "1") {
      Get.offAllNamed('/splash');
    }
  }
} 