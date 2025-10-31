import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/screens/enquire_screen/controllers/enquire_screen_controller.dart';
import 'package:homy/utils/helpers/helper_utils.dart';
import 'package:homy/utils/my_text_style.dart';

class DetailsPage extends StatelessWidget {
  final UserData? userData;
  final EnquireInfoScreenController controller;

  const DetailsPage({super.key, this.userData, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userData?.about != null && userData!.about!.isNotEmpty) 
              _buildSection(
                title: 'About',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DetectableText(
                    text: userData?.about ?? '',
                    detectionRegExp: RegExp(r"\B#\w\w+"),
                    basicStyle: MyTextStyle.productLight(
                      size: 16,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                    moreStyle: MyTextStyle.productMedium(
                      size: 14,
                      color: Get.theme.colorScheme.primary,
                    ),
                    lessStyle: MyTextStyle.productMedium(
                      size: 14,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: 'Contact Information',
              child: Container(
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (userData?.address != null)
                      _buildContactTile(
                        icon: Icons.location_on_rounded,
                        text: userData?.address ?? '',
                      ),
                    if (userData?.phoneOffice != null)
                      _buildContactTile(
                        icon: Icons.business,
                        text: HelperUtils.maskSensitiveInfo(userData?.phoneOffice ?? '', isEmail: false),
                        showDivider: true,
                      ),
                    if (userData?.mobileNo != null)
                      _buildContactTile(
                        icon: Icons.phone_android,
                        text: HelperUtils.maskSensitiveInfo(userData?.mobileNo ?? '', isEmail: false),
                        showDivider: true,
                      ),
                    if (userData?.email != null)
                      _buildContactTile(
                        icon: Icons.email_rounded,
                        text: HelperUtils.maskSensitiveInfo(userData?.email ?? '', isEmail: true),
                        showDivider: true,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: MyTextStyle.productMedium(
            size: 20,
            color: Get.theme.colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String text,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Get.theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: MyTextStyle.productLight(
                    size: 16,
                    color: Get.theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Get.theme.colorScheme.outline.withOpacity(0.2),
          ),
      ],
    );
  }

  
}
