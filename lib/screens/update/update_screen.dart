import 'package:homy/common/ui.dart';
import 'package:homy/common/widgets/custom_button.dart';
import 'package:homy/utils/constants/image_string.dart';
import 'package:homy/utils/dimensions.dart';
import 'package:homy/utils/my_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../services/config_service.dart';

class UpdateScreen extends StatefulWidget {
  final bool isUpdate;
  const UpdateScreen({super.key, required this.isUpdate});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final configService = Get.find<ConfigService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(
              widget.isUpdate ? MImages.update : MImages.maintenance,
              width: MediaQuery.of(context).size.height * 0.4,
              height: MediaQuery.of(context).size.height * 0.4,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              widget.isUpdate ? configService.appConfig.updateTitle ?? 'Update' : configService.appConfig.maintenanceMessage.tr,
              style: MyTextStyle.robotoBold.copyWith(
                  fontSize: MediaQuery.of(context).size.height * 0.023,
                  color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              widget.isUpdate
                  ? configService.appConfig.updateMessage.tr
                  : 'We will be right back'.tr,
              textAlign: TextAlign.center,
              style: Get.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color: Get.theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            SizedBox(
                height: widget.isUpdate
                    ? MediaQuery.of(context).size.height * 0.04
                    : 0),
            widget.isUpdate
                ? CustomButton(
                    buttonText: 'Update Now'.tr,
                    onPressed: () async {
                      String? appUrl = 'https://google.com';
                      final configService = await ConfigService.getConfig();

                      if (GetPlatform.isAndroid) {
                        appUrl = configService.appVersion.appUrlAndroid;
                      } else if (GetPlatform.isIOS) {
                        appUrl = configService.appVersion.appUrlIos;
                      }
                      if (await canLaunchUrlString(appUrl!)) {
                        launchUrlString(appUrl,
                            mode: LaunchMode.externalApplication);
                      } else {
                        Get.showSnackbar(CommonUI.ErrorSnackBar(
                            message: 'Can not launch $appUrl'));
                      }
                    })
                : const SizedBox(),
          ]),
        ),
      ),
    );
  }
}
